package main.java.com.aceex.roncador.model;

import java.io.Serializable;

public class PedidoErro implements Serializable {
	private static final long serialVersionUID = 1L;
	
	private Integer versao;
	private String empresa;
	private String pedido;
	private String produto;
	private String mensagem;

	public PedidoErro() {}

	public Integer getVersao() {
		return versao;
	}

	public void setVersao(Integer versao) {
		this.versao = versao;
	}

	public String getEmpresa() {
		return empresa;
	}


	public void setEmpresa(String empresa) {
		this.empresa = empresa;
	}


	public String getPedido() {
		return pedido;
	}

	public void setPedido(String pedido) {
		this.pedido = pedido;
	}

	public String getProduto() {
		return produto;
	}

	public void setProduto(String produto) {
		this.produto = produto;
	}

	public String getMensagem() {
		return mensagem;
	}

	public void setMensagem(String mensagem) {
		this.mensagem = mensagem.trim();
	}
		
}
