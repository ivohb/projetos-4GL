<?PHP
 //-----------------------------------------------------------------------------
 //Desenvolvedor: Henrique Antonio Conte
 //Manutenção:    
 //Data manutenção:21/06/2005
 //Modulo:         VDP
 //Processo:       Notas Fiscais Emitidas por Periodo
 //Versão:         1.0
  $prog="vdp/vdp0017";
  $versao=1;
 //-----------------------------------------------------------------------------
 include("../../bibliotecas/inicio.inc");
 include("../../bibliotecas/usuario.inc");
 if($nome_<>"")
 {
  include("../../bibliotecas/style.inc");
  printf("<tr> <FORM METHOD='POST' ACTION='vdp0017_a.php'></tr>");
  include("../../bibliotecas/empresa.inc");
  printf("</tr><tr>");
  include("../../bibliotecas/autentica.inc");
  printf("</table><table><tr>
        <td width='750' style=$n_style      align='left'>
         <input type='checkbox' name='num_ordens' value='S' >
         Numero de Ordem??  </td></tr><tr>");
  printf("</table><table><tr>
        <td width='750' style=$n_style      align='left'>
         <input type='checkbox' name='q_data' value='S' >
         Quebra por Data:  </td></tr><tr>");

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
