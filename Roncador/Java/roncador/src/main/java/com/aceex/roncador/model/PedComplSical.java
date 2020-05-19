package main.java.com.aceex.roncador.model;

import java.io.Serializable;

public class PedComplSical implements Serializable {
	private static final long serialVersionUID = 1L;
	
	private Integer num_versao;
	private String cnpj_empresa; 
	private String num_pedido;     
	private String obs;
	private String obs_nota_fiscal;
	
	public PedComplSical() {}

	public Integer getNum_versao() {
		return num_versao;
	}

	public void setNum_versao(Integer num_versao) {
		this.num_versao = num_versao;
	}

	public String getCnpj_empresa() {
		return cnpj_empresa;
	}

	public void setCnpj_empresa(String cnpj_empresa) {
		this.cnpj_empresa = cnpj_empresa;
	}

	public String getNum_pedido() {
		return num_pedido;
	}

	public void setNum_pedido(String num_pedido) {
		this.num_pedido = num_pedido;
	}

	public String getObs() {
		return obs;
	}

	public void setObs(String obs) {
		this.obs = obs;
	}

	public String getObs_nota_fiscal() {
		return obs_nota_fiscal;
	}

	public void setObs_nota_fiscal(String obs_nota_fiscal) {
		this.obs_nota_fiscal = obs_nota_fiscal;
	}
		
}
