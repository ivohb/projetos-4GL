<?PHP
 //-----------------------------------------------------------------------------
 //Desenvolvedor: Henrique Antonio Conte
 //Manuten��o:    
 //Data manuten��o:21/06/2005
 //M�dulo:         VDP
 //Processo:       Emissao Relat�rio Comissoes
 //Vers�o:         1.0
 $prog="vdp/vdp0010";
 $versao="1";
 //-----------------------------------------------------------------------------

 include("../../bibliotecas/inicio.inc");
 include("../../bibliotecas/usuario.inc");
 if($nome_<>"")
 {
  include("../../bibliotecas/style.inc");
  printf("<tr> <FORM METHOD='POST' ACTION='vdp0010_a.php'></tr>");
  include("../../bibliotecas/empresa.inc");
     printf("<td width='20'  style=$n_style colspan='2'      align='left'>
       <b><font face='Arial, Helvetica, sans-serif' size='2' color=$c_color>
       Tipo:</font></b>
     </td>
     <td width='50'  style=$n_style colspan='5'     align='left'>
      <select name='tipo'>");
      printf("<option value='F'selected >Funcionario</option>");
      printf("<option value='S'>Supervisor</option>");
      printf("<option value='R'>Representante</option>");
      printf("<option value='A'>Autonomo</option>");
      printf("<option value='C'>Func.Repre</option>");
      printf("<option value='K'>Teleatendimento</option>");
      printf("</select>
     </td></tr><tr>" );
     printf("<td width='20'  style=$n_style colspan='2'      align='left'>
       <b><font face='Arial, Helvetica, sans-serif' size='2' color=$c_color>
       Dados:</font></b>
     </td>
     <td width='50'  style=$n_style colspan='5'     align='left'>
      <select name='dados'>");
      printf("<option value='T' selected>Todos</option>");
      printf("<option value='A'>Lancados</option>");
      printf("<option value='G'>Gerados</option>");
      printf("</select>
     </td>" );

  include("../../bibliotecas/mes_ref.inc");
  include("../../bibliotecas/ano_ref.inc");
  include("../../bibliotecas/autentica.inc");
  printf("</tr> 
        </tr>
        <tr>
         <td width='50'  colspan='5' style=$n_style      align='center'>
         <input type='submit' name='Confirmar' value='Emitir Relatorio'>
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
