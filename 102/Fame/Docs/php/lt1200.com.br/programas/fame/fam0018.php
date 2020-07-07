<?PHP
 //-----------------------------------------------------------------------------
 //Desenvolvedor: Henrique Antonio Conte
 //Manutenï¿½o:
 //Data manutenï¿½o:28/11/2005
 //Mdulo:         Fame
 //Processo:      Relatório de Clientes com direito a Relógio
 //Versï¿½:         1.0
 $versao=1;
 $prog="fame/fam0018";
 //-----------------------------------------------------------------------------

 include("../../bibliotecas/inicio.inc");
 include("../../bibliotecas/usuario.inc");
 if($nome_<>"")
 {
  include("../../bibliotecas/style.inc");
  printf("<tr> <FORM METHOD='POST' ACTION='fam0018_a.php'></tr>");
  include("../../bibliotecas/autentica.inc");
  printf("</table><table><tr>
        <td width='200'  style=$n_style      align='left'>
         <input type='checkbox' name='det' value='S' >
         Relatorio de Todos com Direito
        </td>");
  printf("<td width='20'  style=$n_style       align='left'>
       <b><font face='Arial, Helvetica, sans-serif' size='2' color=$c_color>
       Processo:</font></b>
    </td>
    <td width='20'  style=$n_style      align='left'>
       <input type='text' name='proc' value='todos' size='5' maxlenght='5' > 
      </td>

      </table>
      <table>
      <tr>
      <td width='50'  style=$n_style      align='center'>
       <input type='submit' name='Confirmar'>
      </td>
      <td width='50'  style=$n_style     align='center'>
       <input type='reset' name='Cancelar'>
      </td>
     </FORM>
     </tr>");
 }else{
  fechar();
  include("../../bibliotecas/negado.inc");
 }
 printf("</html>");
?>






