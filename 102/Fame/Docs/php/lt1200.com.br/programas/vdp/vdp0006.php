<?PHP
 //-----------------------------------------------------------------------------
 //Desenvolvedor: Henrique Antonio Conte
 //Manutenção:    
 //Data manutenção:21/06/2005
 //Módulo:         VDP
 //Processo:       Gerar Dados de Comissoes
 //Versão:         1.0
 $prog="vdp/vdp0006";
 $versao="1";
 //-----------------------------------------------------------------------------

 include("../../bibliotecas/inicio.inc");
 include("../../bibliotecas/usuario.inc");
 if($nome_<>"")
 {
  include("../../bibliotecas/style.inc");
  printf("<tr> <FORM METHOD='POST' ACTION='vdp0006_a.php'></tr>");
  include("../../bibliotecas/empresa.inc");
     printf("<td width='20'  style=$n_style colspan='2'      align='left'>
       <b><font face='Arial, Helvetica, sans-serif' size='2' color=$c_color>
       Tipo:</font></b>
     </td>
     <td width='50'  style=$n_style colspan='5'     align='left'>
      <select name='tipo'>");
      printf("<option value='' selected >Selecione Tipo</option>");
      printf("<option value='F'>Funcionario</option>");
      printf("<option value='R'>Representante</option>");
      printf("<option value='A'>Autonomo</option>");
      printf("<option value='C'>Func.Repre</option>");
      printf("<option value='K'>Teleatendimento</option>");
      printf("</select>
     </td></tr><tr>" );



  include("../../bibliotecas/data_ini.inc");
  include("../../bibliotecas/data_fin.inc");
  include("../../bibliotecas/autentica.inc");
  printf("</tr> 
        <tr>
         <td width='50'  colspan='5' style=$n_style      align='center'>
         <input type='submit' name='Confirmar' value='Gerar Comissoes'>
        </td>
        <td width='50'  colspan='5' style=$n_style     align='center'>
         <input type='reset' name='Cancelar' value='Limpar Campos'>
        </td>
       </tr>
      </FORM>");
 }else{
  fechar();
  include("../../bibliotecas/negado.inc");
 }
 printf("</html>");
?>
