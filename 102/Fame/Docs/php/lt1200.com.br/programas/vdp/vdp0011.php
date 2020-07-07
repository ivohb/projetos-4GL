<?PHP
 //-----------------------------------------------------------------------------
 //Desenvolvedor: Henrique Antonio Conte
 //Manutenção:    
 //Data manutenção:21/06/2005
 //Modulo:         VDP
 //Processo:       Notas Fiscais Emitidas por Periodo
 //Versão:         1.0
  $prog="vdp/vdp0011";
  $versao=1;
 //-----------------------------------------------------------------------------
 include("../../bibliotecas/inicio.inc");
 include("../../bibliotecas/usuario.inc");
 if($nome_<>"")
 {
  include("../../bibliotecas/style.inc");
  printf("<tr> <FORM METHOD='POST' ACTION='vdp0011_a.php'></tr>");
  include("../../bibliotecas/empresa.inc");
  printf("</tr><tr>");
  include("../../bibliotecas/data_ini.inc");
  include("../../bibliotecas/data_fin.inc");
  include("../../bibliotecas/autentica.inc");
  printf("</table><table>");
  if($erep<>"S")
  {
   printf("</tr><tr><td width='150'  style=$n_style  align='left'>
          <i><font face='Arial, Helvetica, sans-serif' size='3' color=$c_color>
          Digite Código do Repres:</font></i>
          </td>
          <td width='50'  style=$n_style      align='left'>
          <input type='text' name='srepres' value='todos' size='10' maxlenght='10'> 
          </td>");

     printf("</table><table><tr>
        <td width='750' style=$n_style      align='left'>
         <input type='checkbox' name='supervisor' value='S' >
         Todos do Supervisor  </td></tr><tr>");
  }
  printf("</table><table><td width='70'  style=$n_style  color=$c_color     align='center'>
           <input type='submit' name='Confirmar' value='Processar'>
           </td>
           </tr>
      </FORM>");
 }else{
  fechar();
  include("../../bibliotecas/negado.inc");
 }
 printf("</html>");
?>
