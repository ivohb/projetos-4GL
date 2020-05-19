package main.java.com.aceex.roncador.model;

import java.io.Serializable;

public class PedItemSical implements Serializable {
	private static final long serialVersionUID = 1L;

	private Integer num_versao;
	private String cnpj_empresa;
	private String total_bruto;
	private String preco_unitario;
	private String cod_produto;
	private String quant_cancelada;
	private String num_pedido;
	private String quant;
	private String prz_entrega;
	private String perc_desc;
	private String total_liquido;
	private String preco_tabela;
	
	public PedItemSical() { }

	
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

	public String getTotal_bruto() {
		return total_bruto;
	}

	public void setTotal_bruto(String total_bruto) {
		this.total_bruto = total_bruto;
	}

	public String getPreco_unitario() {
		return preco_unitario;
	}

	public void setPreco_unitario(String preco_unitario) {
		this.preco_unitario = preco_unitario;
	}

	public String getCod_produto() {
		return cod_produto;
	}

	public void setCod_produto(String cod_produto) {
		this.cod_produto = cod_produto;
	}

	public String getQuant_cancelada() {
		return quant_cancelada;
	}

	public void setQuant_cancelada(String quant_cancelada) {
		this.quant_cancelada = quant_cancelada;
	}
	
	public String getPrz_entrega() {
		return prz_entrega;
	}

	public void setPrz_entrega(String prz_entrega) {
		this.prz_entrega = prz_entrega;
	}

	public String getNum_pedido() {
		return num_pedido;
	}

	public void setNum_pedido(String num_pedido) {
		this.num_pedido = num_pedido;
	}

	public String getQuant() {
		return quant;
	}

	public void setQuant(String quant) {
		this.quant = quant;
	}

	public String getPerc_desc() {
		return perc_desc;
	}

	public void setPerc_desc(String perc_desc) {
		this.perc_desc = perc_desc;
	}

	public String getTotal_liquido() {
		return total_liquido;
	}

	public void setTotal_liquido(String total_liquido) {
		this.total_liquido = total_liquido;
	}

	public String getPreco_tabela() {
		return preco_tabela;
	}

	public void setPreco_tabela(String preco_tabela) {
		this.preco_tabela = preco_tabela;
	}

}
