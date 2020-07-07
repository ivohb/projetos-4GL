package br.com.SGIURD.logica;

import java.sql.Connection;

import org.apache.struts.action.ActionForm;
import org.json.JSONArray;
import org.json.JSONException;
import org.json.JSONObject;

import br.com.SGIURD.Interface.ILogica;
import br.com.SGIURD.form.PaisesForm;
import br.com.SGIURD.jdbc.dao.IdiomaDAO;
import br.com.SGIURD.jdbc.dao.PaisesDAO;
import br.com.SGIURD.utils.Simplifying;

public class PaisesLogica implements ILogica {
	
	private Connection connection;
	private String audit_tipo;
	JSONObject j = new JSONObject();
	PaisesDAO dao;
	Simplifying s = new Simplifying();
	
	public PaisesLogica(Connection connection) {
		this.connection = connection;
		dao = new PaisesDAO(connection);
	}

	@Override
	public JSONObject salva(ActionForm form) throws JSONException {
		PaisesForm pais = (PaisesForm) form;		
	    JSONObject jPais = new JSONObject(pais.getPais()).getJSONObject("den_pais");
		pais = s.JsonToBean(pais, new JSONObject(pais.getPais()));
		
		String[] names = JSONObject.getNames(jPais);
					
		for (int i = 0; i < jPais.length(); i++) {
			PaisesForm paisesForm = new PaisesForm();
			paisesForm.setCod_pais(pais.getCod_pais());
			paisesForm.setDen_pais(jPais.getString(names[i]));
			paisesForm.setCod_language(names[i].toLowerCase());
			paisesForm.setCod_ddi(pais.getCod_ddi());
			paisesForm.setFor_data(pais.getFor_data());
			paisesForm.setCod_usuario(pais.getCod_usuario());
			
			if(paisesForm.getDen_pais() != null && paisesForm.getDen_pais().trim().length() > 0){
			
				if(dao.isEntidadeExiste(form)){
					//verifica a posicao 3 do bit - Alteracao (* posicoes dos bits da direita para a esqueda)
					if(pais.getPermissao().contains("editar")){
						j= dao.altera(paisesForm);
						audit_tipo = "ALTERACAO";
					}
				} else {
					//verifica a posicao 2 do bit - Inclusao (* posicoes dos bits da direita para a esqueda)
					if(pais.getPermissao().contains("inserir")){	
						j= dao.insere(paisesForm);
						audit_tipo = "INCLUSAO";
					}
				}
			} else {
				j.put("errorCode", 120);
				j.put("errorDesc", "Erro: Verifique campos vazios.");
			}
		}
		
		JSONObject jAuditoria = new JSONObject();
		jAuditoria.put("cod_pais", pais.getCod_pais());
		jAuditoria.put("modulo", pais.getModulo_auditoria());
		jAuditoria.put("modulo_auditoria", pais.getModulo_auditoria());
		jAuditoria.put("endereco_ip", pais.getEndereco_ip());
		jAuditoria.put("cod_usuario", pais.getCod_usuario());
		jAuditoria.put("texto_auditoria", "REALIZADA A OPERACAO DE "+ audit_tipo +" NO PAIS.");
		jAuditoria.put("campos", "COD_PAIS:" + pais.getCod_pais()
								+"; DEN_PAIS:" + pais.getDen_pais()
								+"; COD_LANGUAGE:" + pais.getCod_language());
		
		j.append("auditoria", jAuditoria);	
		return j;		
	}

	@Override
	public JSONObject seleciona(ActionForm form) throws JSONException {
		PaisesForm pais = (PaisesForm) form;
		if(pais.getPermissao() != null && pais.getPermissao().contains("visualizar")){		
			return dao.seleciona(form);
		}		
		j.put("errorCode","199");
		j.put("errorDesc","ACAO NAO PERMITIDA");
		return j;
	}

	@Override
	public JSONObject filtra(ActionForm form) throws JSONException {
		return dao.filtra(form);
	}
	
	public JSONObject filtracomLocalEPermissao(ActionForm form) throws JSONException {
		PaisesForm pais = (PaisesForm) form;
		if(pais.getPermissaoLocalidade() != null){
			return dao.filtracomLocalEPermissao(form);
		}
		
		j.put("errorCode","199");
		j.put("errorDesc","ACAO NAO PERMITIDA");
		return j;
	}	

	public JSONObject estruturaObjeto(PaisesForm pais) throws JSONException {
		try{
			JSONObject IdiomasSistema = new IdiomaDAO(connection).buscaIdiomasSistema();
			JSONArray jIdiomas = IdiomasSistema.getJSONArray("idiomas");
			
			JSONObject json = new JSONObject();
			JSONObject jsonPaises = new JSONObject();
			for (int i = 0; i < jIdiomas.length(); i++) {
				json.put(jIdiomas.getString(i), "");
				
				jsonPaises.put("den_pais", json);
			}
			
			jsonPaises.put("cod_pais", "");
			jsonPaises.put("cod_ddi", "");
			jsonPaises.put("for_data", "");
			
			j.put("errorCode","0");
			j.put("errorDesc","Sucesso");
			j.put("pais", jsonPaises);
		} catch (Exception e) {
			j.put("errorCode", 302);
			j.put("errorDesc","Erro: PaisesDAO.estruturaObjeto(). Erro de Sintaxe.");
			System.out.println("PaisesDAO.estruturaObjeto(). Erro de Sintaxe.");
		}
		return j;	
	}	
}
