<?PHP
 //-----------------------------------------------------------------------------
 //Desenvolvedor: Henrique Antonio Conte
 //Manuten�o:
 //Data manuten�o:22/08/2005
 //Mdulo:         Fame
 //Processo:      Arquivo remessa CDV
 //Vers�:         1.0
 $versao=1;
 $prog="fame/fam0008";
 //-----------------------------------------------------------------------------

 include("../../bibliotecas/inicio.inc");
 include("../../bibliotecas/usuario.inc");
 if($nome_<>"")
 {
  include("../../bibliotecas/style.inc");
  printf("<tr> <FORM METHOD='POST' ACTION='fam0008_a.php'></tr>");
  include("../../bibliotecas/autentica.inc");
  include("../../bibliotecas/empresa.inc");
  printf("</tr><tr>
         <td width='50'  style=$n_style colspan='5'     align='center'>
         <i><font face='Arial, Helvetica, sans-serif' size='3' color=$c_color>
           Agencia:</font></i>
         </td>
         <td width='20'  style=$n_style colspan='2'      align='left'>
          <font face='Arial, Helvetica, sans-serif' size='3' color=$c_color>
         <input type='text' name='agencia' value='00165' size='5' maxlenght='5'>
        </td>

         <td width='50'  style=$n_style colspan='5'     align='center'>
         <i><font face='Arial, Helvetica, sans-serif' size='3' color=$c_color>
           Razao:</font></i>
         </td>
         <td width='20'  style=$n_style colspan='2'      align='left'>
          <font face='Arial, Helvetica, sans-serif' size='3' color=$c_color>
         <input type='text' name='razao' value='07050' size='5' maxlenght='5'>
        </td>
         <td width='50'  style=$n_style colspan='5'     align='center'>
         <i><font face='Arial, Helvetica, sans-serif' size='3' color=$c_color>
           Conta.Corrente:</font></i>
         </td>
         <td width='20'  style=$n_style colspan='2'      align='left'>
          <font face='Arial, Helvetica, sans-serif' size='3' color=$c_color>
         <input type='text' name='c_corrente' value='00000450' size='8' maxlenght='8'>
        </td>
         <td width='50'  style=$n_style colspan='5'     align='center'>
         <i><font face='Arial, Helvetica, sans-serif' size='3' color=$c_color>
           Dado:</font></i>
         </td>
         <td width='20'  style=$n_style colspan='2'      align='left'>
          <font face='Arial, Helvetica, sans-serif' size='3' color=$c_color>
         <input type='text' name='dado' value='03496' size='5' maxlenght='5'>
        </td>
         <td width='50'  style=$n_style colspan='5'     align='center'>
         <i><font face='Arial, Helvetica, sans-serif' size='3' color=$c_color>
           Dado1:</font></i>
         </td>
         <td width='20'  style=$n_style colspan='2'      align='left'>
          <font face='Arial, Helvetica, sans-serif' size='3' color=$c_color>
         <input type='text' name='dado1' value='298' size='3' maxlenght='3'>
        </td>
        </tr>
        <tr>
         <td width='50'  style=$n_style colspan='5'     align='center'>
         <i><font face='Arial, Helvetica, sans-serif' size='3' color=$c_color>
           Nome:</font></i>
         </td>
         <td width='60'  style=$n_style colspan='6'      align='left'>
          <font face='Arial, Helvetica, sans-serif' size='3' color=$c_color>
         <input type='text' name='n_fame' value='F.A.M.E.-FB AP MT EL LTDA' size='35' maxlenght='25'>
        </td>
        ");

  printf("
      <td width='10'  style=$n_style colspan='1'     align='left'>
       <input type='hidden' value='G' name='prog_c' size='1' maxlenght='1' readonly>
      </td>
       <td width='80'  style=$n_style colspan='8'      align='center'>
       <input type='submit' name='Confirmar' value='Gerar Arquivo'>
      </td>
     </tr>
     </FORM>");

 }else{
  fechar();
  include("../../bibliotecas/negado.inc");
 }
 printf("</html>");
?>






