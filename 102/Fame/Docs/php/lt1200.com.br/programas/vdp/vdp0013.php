<?PHP
 //-----------------------------------------------------------------------------
 //Desenvolvedor: Henrique Antonio Conte
 //Manutenção:    
 //Data manutenção:21/06/2005
 //Modulo:         VDP
 //Processo:       Notas Fiscais Emitidas por Periodo
 //Versão:         1.0
  $prog="vdp/vdp0013";
  $versao=1;
 //-----------------------------------------------------------------------------
 include("../../bibliotecas/inicio.inc");
 include("../../bibliotecas/usuario.inc");
 if($nome_<>"")
 {
  include("../../bibliotecas/style.inc");
  printf("<tr> <FORM METHOD='POST' ACTION='vdp0013_a.php'></tr>");
  include("../../bibliotecas/empresa.inc");
  printf("</tr><tr>");
  include("../../bibliotecas/data_ini.inc");
  include("../../bibliotecas/data_fin.inc");
  include("../../bibliotecas/autentica.inc");
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
