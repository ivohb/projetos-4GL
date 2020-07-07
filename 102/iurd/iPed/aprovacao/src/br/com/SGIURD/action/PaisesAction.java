package br.com.SGIURD.action;

import java.sql.Connection;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import org.apache.struts.action.Action;
import org.apache.struts.action.ActionForm;
import org.apache.struts.action.ActionForward;
import org.apache.struts.action.ActionMapping;
import org.json.JSONObject;

import br.com.SGIURD.form.PaisesForm;
import br.com.SGIURD.logica.PaisesLogica;

public class PaisesAction extends Action {
	public ActionForward execute(ActionMapping map, ActionForm form,
			HttpServletRequest request, HttpServletResponse response)
			throws Exception {
		//busca a conexao pendurada na requisicao
		Connection connection = (Connection) request.getAttribute("connection");		
		
		//entra
		PaisesForm pais = (PaisesForm) form;
		pais.setPermissao(request.getAttribute("permissao") != null && !request.getAttribute("permissao").equals("{}") ? request.getAttribute("permissao").toString() : null);
		pais.setPermissaoLocalidade(request.getAttribute("permissaoLocalidade") != null ? request.getAttribute("permissaoLocalidade").toString(): null);
		pais.setCod_usuario(request.getAttribute("cod_usuario") != null ? request.getAttribute("cod_usuario").toString() : null);
		pais.setCod_usuario_permis(request.getAttribute("cod_usuario") != null ? request.getAttribute("cod_usuario").toString() : null);
		
		// sai dao
		PaisesLogica logica 	= new PaisesLogica(connection);
		JSONObject jsonObject 	= new JSONObject();
		// acao = 0 => Cadastra Paises
		// acao = 2 => Seleciona Pais
		// acao = 3 => Lista Pais com Permissao e Local
		// acao = 5 => Lista Pais
		// acao = 99=> Estrutura 
		
		
		//sai token
		/*
		 * NAO IREMOS REALIZAR A EXCLUSAO DE PAISES, DEVIDO AO CONTROLE DAS DEPENDENCIAS
		 */
		pais.setEndereco_ip(request.getRemoteAddr());
		pais.setModulo_auditoria("CADASTROS");		
		pais.setCod_modulo(5);
		
		//entra logica
		switch (pais.getAcao()) {
		case 0:
			jsonObject = logica.salva(pais);
			jsonObject.put("transaction", true);
			break;
		case 2:
			jsonObject = logica.seleciona(pais);
			break;					
		case 3:
			jsonObject = logica.filtracomLocalEPermissao(pais);
			break;
		case 5:
			jsonObject = logica.filtra(pais);
			break;
		case 99:
			jsonObject = logica.estruturaObjeto(pais);
			break;
		default:
			jsonObject.put("errorCode", 198);
			jsonObject.put("errorDesc", "PaisesAction. Acao nao encontrada.");			
		}
		
		if(request.getAttribute("permissao") != null){
			jsonObject.put("permissao", request.getAttribute("permissao"));
		}
		
		response.getWriter().write(jsonObject.toString());
		return null;
	}
}
