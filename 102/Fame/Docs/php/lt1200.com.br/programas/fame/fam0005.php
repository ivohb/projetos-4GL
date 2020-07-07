<?PHP
 //-----------------------------------------------------------------------------
 //Desenvolvedor: Henrique Antonio Conte
 //Manuten�o:
 //Data manuten�o:22/08/2005
 //Mdulo:         Fame
 //Processo:        Cadastro de Motoristas
 //Vers�:         1.0
 $versao=1;
 $prog="fame/fam0005";
 //-----------------------------------------------------------------------------

 include("../../bibliotecas/inicio.inc");
 include("../../bibliotecas/usuario.inc");
 if($nome_<>"")
 {
  include("../../bibliotecas/style.inc");
  printf("<tr> <FORM METHOD='POST' ACTION='fam0005_a.php'></tr>");
  include("../../bibliotecas/autentica.inc");
  include("../../bibliotecas/empresa.inc");
  printf("<td width='50'  style=$n_style colspan='5'     align='center'>
         <i><font face='Arial, Helvetica, sans-serif' size='3' color=$c_color>
           Entrega:</font></i>
         </td>
         <td width='20'  style=$n_style colspan='2'      align='left'>
          <font face='Arial, Helvetica, sans-serif' size='3' color=$c_color>
         <input type='text' name='num_emb' value='novo' size='6' maxlenght='6'>
        </td>");

  printf("<tr>
          <td width='50'  style=$n_style colspan='5'     align='center'>
            <i><font face='Arial, Helvetica, sans-serif' size='3' color=$c_color>
             Chapa:</font></i>
          </td>
         <td width='100'  style=$n_style colspan='10'  >
          <select name='chapa'>");
  printf("<option value='$chapa'  selected>$chapa</option>");

  $selec_caminhoes="select  *
                        from lt1200_caminhoes a
                       order by chapa
                   ";
  $res_caminhoes = $cconnect("lt1200",$ifx_user,$ifx_senha);
  $result_caminhoes = $cquery($selec_caminhoes,$res_caminhoes);

  $mat_caminhoes=$cfetch_row($result_caminhoes);
  while(is_array($mat_caminhoes))
  {
   $chapa=trim($mat_caminhoes["chapa"]);
   printf("<option value='$chapa' >$chapa</option>");
   $mat_caminhoes=$cfetch_row($result_caminhoes);
  }
  printf("</select>
         </td> ");


  printf("<tr>
          <td width='50'  style=$n_style colspan='5'     align='center'>
            <i><font face='Arial, Helvetica, sans-serif' size='3' color=$c_color>
             Motorista:</font></i>
          </td>
         <td width='100'  style=$n_style colspan='10'  >
          <select name='cpf_moto'>");

  $selec_motoristas="select  *
                        from lt1200_motoristas a
                       order by nome_moto
                   ";
  $res_motoristas = $cconnect("lt1200",$ifx_user,$ifx_senha);
  $result_motoristas = $cquery($selec_motoristas,$res_motoristas);
  $mat_motoristas=$cfetch_row($result_motoristas);
  while(is_array($mat_motoristas))
  {
   $cpf_moto=trim($mat_motoristas["cpf_moto"]);
   $nome_moto=trim($mat_motoristas["nome_moto"]);
   printf("<option value='$cpf_moto' >$nome_moto</option>");
   $mat_motoristas=$cfetch_row($result_motoristas);
  }
  printf("</select>
         </td> ");

  printf("<FORM METHOD='POST' ACTION='fam0005_a.php'>");
  printf("</tr>
      <tr>
      <td width='10'  style=$n_style colspan='1'     align='left'>
       <input type='hidden' value='X' name='prog_c' size='1' maxlenght='1' readonly>
      </td>
     </tr>
     <tr>
       <td width='50'  style=$n_style colspan='5'     align='center'>
         <i><font face='Arial, Helvetica, sans-serif' size='3' color=$c_color>
           Data.Saida:</font></i>
         </td>
      <td width='20'  style=$n_style colspan='2'      align='left'>
       <font face='Arial, Helvetica, sans-serif' size='3' color=$c_color>
       <input type='text' name='data_saida' value='".$data."'
        size='10' maxlenght='10'>
      </td>

       <td width='50'  style=$n_style colspan='5'     align='center'>
         <i><font face='Arial, Helvetica, sans-serif' size='3' color=$c_color>
           Apolice:</font></i>
         </td>
      <td width='20'  style=$n_style colspan='2'      align='left'>
       <font face='Arial, Helvetica, sans-serif' size='3' color=$c_color>
       <input type='text' name='apolice' value='000002' size='6' maxlenght='6'>
      </td>

      <td width='20'  style=$n_style colspan='2'      align='left'>
       <font face='Arial, Helvetica, sans-serif' size='3' color=$c_color>
       <input type='text' name='comp_apolice' value='258' size='3' maxlenght='3'>
      </td>
       <td width='80'  style=$n_style colspan='8'      align='center'>
       <input type='submit' name='Confirmar' value='Itens da Entrega'>
      </td>
     </tr>
     </FORM>");

 }else{
  fechar();
  include("../../bibliotecas/negado.inc");
 }
 printf("</html>");
?>






