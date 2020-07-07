package br.com.SGIURD.form;

import org.apache.struts.action.ActionForm;


public class AuditoriaForm extends ActionForm {

	/**
	 * 
	 */
	 private static final long serialVersionUID = 1L;
	private int cod_modulo;
	private String 
			cod_usuario, modulo_auditoria, endereco_ip, cod_language,cod_pais,		
			postUnico, fieldList, whereClause, orderClause, size, offset,
			caminhoImgMail, caminhoFotoMail, token, iesTipoPessoa,
			caminho, cod_usuario_permis,cod_pessoa_user , errorCode , modulo_testemunho,cod_language_user,
			senha_usuario , data, permissao, permissaoLocalidade;

	public int getCod_modulo() {
		return cod_modulo;
	}

	public void setCod_modulo(int cod_modulo) {
		this.cod_modulo = cod_modulo;
	}

	public String getCod_usuario() {
		return cod_usuario;
	}

	public void setCod_usuario(String cod_usuario) {
		this.cod_usuario = cod_usuario;
	}

	public String getModulo_auditoria() {
		return modulo_auditoria;
	}

	public void setModulo_auditoria(String modulo_auditoria) {
		this.modulo_auditoria = modulo_auditoria;
	}

	public String getEndereco_ip() {
		return endereco_ip;
	}

	public void setEndereco_ip(String endereco_ip) {
		this.endereco_ip = endereco_ip;
	}

	public String getCod_language() {
		return cod_language;
	}

	public void setCod_language(String cod_language) {
		this.cod_language = cod_language;
	}

	public String getFieldList() {
		return fieldList;
	}

	public void setFieldList(String fieldList) {
		this.fieldList = fieldList;
	}

	public String getWhereClause() {
		return whereClause;
	}

	public void setWhereClause(String whereClause) {
		this.whereClause = whereClause;
	}

	public String getOrderClause() {
		return orderClause;
	}

	public void setOrderClause(String orderClause) {
		this.orderClause = orderClause;
	}

	public String getSize() {
		return size;
	}

	public void setSize(String size) {
		this.size = size;
	}

	public String getOffset() {
		return offset;
	}

	public void setOffset(String offset) {
		this.offset = offset;
	}

	public String getCaminhoImgMail() {
		return caminhoImgMail;
	}

	public void setCaminhoImgMail(String caminhoImgMail) {
		this.caminhoImgMail = caminhoImgMail;
	}

	public String getCaminhoFotoMail() {
		return caminhoFotoMail;
	}

	public void setCaminhoFotoMail(String caminhoFotoMail) {
		this.caminhoFotoMail = caminhoFotoMail;
	}

	public void setToken(String token) {
		this.token = token;
	}

	public String getToken() {
		return token;
	}

	public void setPostUnico(String postUnico) {
		this.postUnico = postUnico;
	}

	public String getPostUnico() {
		return postUnico;
	}

	public void setIesTipoPessoa(String iesTipoPessoa) {
		this.iesTipoPessoa = iesTipoPessoa;
	}

	public String getIesTipoPessoa() {
		return iesTipoPessoa;
	}

	public void setCaminho(String caminho) {
		this.caminho = caminho;
	}

	public String getCaminho() {
		return caminho;
	}

	public void setCod_usuario_permis(String cod_usuario_permis) {
		this.cod_usuario_permis = cod_usuario_permis;
	}

	public String getCod_usuario_permis() {
		return cod_usuario_permis;
	}

	public void setCod_pessoa_user(String cod_pessoa_user) {
		this.cod_pessoa_user = cod_pessoa_user;
	}

	public String getCod_pessoa_user() {
		return cod_pessoa_user;
	}

	public void setErrorCode(String errorCode) {
		this.errorCode = errorCode;
	}

	public String getErrorCode() {
		return errorCode;
	}

	public void setModulo_testemunho(String modulo_testemunho) {
		this.modulo_testemunho = modulo_testemunho;
	}

	public String getModulo_testemunho() {
		return modulo_testemunho;
	}

	public void setCod_language_user(String cod_language_user) {
		this.cod_language_user = cod_language_user;
	}

	public String getCod_language_user() {
		return cod_language_user;
	}

	public void setSenha_usuario(String senha_usuario) {
		this.senha_usuario = senha_usuario;
	}

	public String getSenha_usuario() {
		return senha_usuario;
	}

	public String getData() {
		return data;
	}

	public void setData(String data) {
		this.data = data;
	}

	public String getCod_pais() {
		return cod_pais;
	}

	public void setCod_pais(String cod_pais) {
		this.cod_pais = cod_pais;
	}

	public String getPermissao() {
		return permissao;
	}

	public void setPermissao(String permissao) {
		this.permissao = permissao;
	}

	public String getPermissaoLocalidade() {
		return permissaoLocalidade;
	}

	public void setPermissaoLocalidade(String permissaoLocalidade) {
		this.permissaoLocalidade = permissaoLocalidade;
	}

}
