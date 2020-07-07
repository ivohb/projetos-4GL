<?PHP
 //-----------------------------------------------------------------------------
 //Desenvolvedor: Henrique Antonio Conte
 //Manutenção:    
 //Data manutenção:22/08/2005
 //Módulo:         Fame
 //Processo:       Cadastro de Caminhoes
 //Versão:         1.0
 $versao=1;
 $prog="fame/fam0003";
 //-----------------------------------------------------------------------------

 include("../../bibliotecas/inicio.inc");
 include("../../bibliotecas/usuario.inc");
 if($nome_<>"")
 {
  include("../../bibliotecas/style.inc");
  printf("<tr> <FORM METHOD='POST' ACTION='fam0003.php'></tr>");
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
   $cons_faz="delete from  lt1200_caminhoes 
            where chapa='".$chapa_c."'
              ";

   $res_faz = $cconnect("lt1200",$ifx_user,$ifx_senha);
   $result_faz = $cquery($cons_faz,$res_faz);
   $prog_c="N";
  }
  if($fazer=='I')
  {
   $cons_faz="insert into  lt1200_caminhoes (
          chapa)
        values ('".$chapa ."')";
   $res_faz = $cconnect("lt1200",$ifx_user,$ifx_senha);
   $result_faz = $cquery($cons_faz,$res_faz);
   $prog_c="N";
  }
  if($fazer=='A')
  {
   $cons_faz="update  lt1200_caminhoes set
                         chapa='".$chapa."'
                     where chapa='".$chapa_c."' ";
   $res_faz = $cconnect("lt1200",$ifx_user,$ifx_senha);
   $result_faz = $cquery($cons_faz,$res_faz);
   $prog_c="N";
  }


  $selec_caminhoes="select  *
                        from lt1200_caminhoes a
                       order by chapa
                   ";
  $res_caminhoes = $cconnect("lt1200",$ifx_user,$ifx_senha);
  $result_caminhoes = $cquery($selec_caminhoes,$res_caminhoes);
  $mat_caminhoes=$cfetch_row($result_caminhoes);

  printf("<tr>
      <td width='750'  style=$n_style colspan='75'     align='center'>
       <b><font face='Arial, Helvetica, sans-serif' size='3' color=$c_color>
       Cadastro de Caminhoes</font></b>
      </td>
     </tr>
     <tr>
      <td width='50'  style=$n_style colspan='5'      align='left'>
       <b><font face='Arial, Helvetica, sans-serif' size='2' color=$c_color>
       CHAPA</font></b>
      </td>
     </tr>
     ");

  printf("<FORM METHOD='POST' ACTION='fam0003.php'>");
  printf("</tr>
      <tr>
      <td width='10'  style=$n_style colspan='1'     align='left'>
       <input type='hidden' value='I' name='prog_c' size='1' maxlenght='1' readonly> 
      </td>
     </tr> 
     <tr>     
      <td width='50'  style=$n_style colspan='5'      align='left'>
       <font face='Arial, Helvetica, sans-serif' size='3' color=$c_color>
       <input type='text' name='chapa'  size='8' maxlenght='8'>  
      </td>
      <td width='80'  style=$n_style colspan='8'      align='center'>
       <input type='submit' name='Confirmar' value='Incluir '>
      </td>
     </tr> 
     </FORM>");

  while (is_array($mat_caminhoes))
  {
   printf("<FORM METHOD='POST' ACTION='fam0003.php'>");
   printf("<tr>

      <td width='50'  style=$n_style colspan='5'      align='left'>
       <font face='Arial, Helvetica, sans-serif' size='3' color=$c_color>
       <input type='text' name='chapa' value='".$mat_caminhoes["chapa"]."'
       size='8' maxlenght='8'>
      </td>

      <td width='0'  style=$n_style colspan='1'     align='left'>
       <input type='hidden' name='chapa_c' size='10' maxlenght='10'
       value='".$mat_caminhoes["chapa"]."' readonly> 
      </td>
      <td width='0'  style=$n_style colspan='1'     align='left'>
       <input type='hidden' value='A' name='prog_c' size='1' maxlenght='1' readonly> 
      </td>
     <td width='10'  style=$n_style colspan='1'      align='center'>
       <input type='submit' name='Confirmar' value='Alterar '>
      </td>
     </FORM>");

   printf("<FORM METHOD='POST' ACTION='fam0003.php'>");
   printf("
      <td width='0'  style=$n_style colspan='1'     align='left'>
       <input type='hidden' name='chapa_c' size='10' maxlenght='10'
       value='".$mat_caminhoes["chapa"]."' readonly> 
      </td>
      <td width='0'  style=$n_style colspan='1'     align='left'>
       <input type='hidden' value='E' name='prog_c' size='1' maxlenght='1' readonly> 
      </td>
      <td width='80'  style=$n_style colspan='8'      align='center'>
       <input type='submit' name='Confirmar' value='Excluir '>
      </td>
     </tr> 
     </FORM>");
   $mat_caminhoes=$cfetch_row($result_caminhoes);
  }
 }else{
  fechar();
  include("../../bibliotecas/negado.inc");
 }
 printf("</html>");
?>






