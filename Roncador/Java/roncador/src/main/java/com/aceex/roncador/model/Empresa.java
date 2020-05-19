package main.java.com.aceex.roncador.model;

import java.io.Serializable;

public class Empresa implements Serializable {
	private static final long serialVersionUID = 1L;

	private String codigo;
	private String cnpj;

	public Empresa() {}

	public String getCodigo() {
		return codigo;
	}

	public void setCodigo(String codigo) {
		this.codigo = codigo;
	}

	public String getCnpj() {
		return cnpj;
	}

	public void setCnpj(String cnpj) {
		this.cnpj = cnpj;
	}
	
	
}
