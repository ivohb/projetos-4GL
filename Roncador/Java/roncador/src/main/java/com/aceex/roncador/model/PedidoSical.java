package main.java.com.aceex.roncador.model;

import java.io.Serializable;

public class PedidoSical implements Serializable {
	private static final long serialVersionUID = 1L;

	private String cod_empresa;
	private Integer num_versao;
	private String versao_atual;
	private String cnpj_empresa;
	private String tipo_pedido;
	private String CNPJ_CPF_cliente;
	private String IE_cliente;
	private String num_pedido;
	private String dt_emissao;
	private String entrega_futura;
	private String cod_portador;
	private String cod_cond_pagto;
	private String CNPJ_CPF_vendedor;
	private Integer pedido_logix;
	private String situacao; // N=Novo C=Criticado I=Integrado
	private String pedido_bloqueado;      
	private String tipo_frete;          

	public PedidoSical() { }

	public String getCod_empresa() {
		return cod_empresa;
	}

	public void setCod_empresa(String cod_empresa) {
		this.cod_empresa = cod_empresa;
	}

	public Integer getNum_versao() {
		return num_versao;
	}

	public void setNum_versao(Integer num_versao) {
		this.num_versao = num_versao;
	}

	public String getVersao_atual() {
		return versao_atual;
	}

	public void setVersao_atual(String versao_atual) {
		this.versao_atual = versao_atual;
	}

	public String getCnpj_empresa() {
		return cnpj_empresa;
	}

	public void setCnpj_empresa(String cnpj_empresa) {
		this.cnpj_empresa = cnpj_empresa;
	}

	public String getTipo_pedido() {
		return tipo_pedido;
	}

	public void setTipo_pedido(String tipo_pedido) {
		this.tipo_pedido = tipo_pedido;
	}

	public String getCNPJ_CPF_cliente() {
		return CNPJ_CPF_cliente;
	}

	public void setCNPJ_CPF_cliente(String CNPJ_CPF_cliente) {
		this.CNPJ_CPF_cliente = CNPJ_CPF_cliente;
	}

	public String getIE_cliente() {
		return IE_cliente;
	}

	public void setIE_cliente(String iE_cliente) {
		IE_cliente = iE_cliente;
	}

	public String getNum_pedido() {
		return num_pedido;
	}

	public void setNum_pedido(String num_pedido) {
		this.num_pedido = num_pedido;
	}

	public String getDt_emissao() {
		return dt_emissao;
	}

	public void setDt_emissao(String dt_emissao) {
		this.dt_emissao = dt_emissao;
	}

	public String getEntrega_futura() {
		return entrega_futura;
	}

	public void setEntrega_futura(String entrega_futura) {
		this.entrega_futura = entrega_futura;
	}

	public String getCod_portador() {
		return cod_portador;
	}

	public void setCod_portador(String cod_portador) {
		this.cod_portador = cod_portador;
	}

	public String getCod_cond_pagto() {
		return cod_cond_pagto;
	}

	public void setCod_cond_pagto(String cod_cond_pagto) {
		this.cod_cond_pagto = cod_cond_pagto;
	}

	public String getCNPJ_CPF_vendedor() {
		return CNPJ_CPF_vendedor;
	}

	public void setCNPJ_CPF_vendedor(String CNPJ_CPF_vendedor) {
		this.CNPJ_CPF_vendedor = CNPJ_CPF_vendedor;
	}

	public Integer getPedido_logix() {
		return pedido_logix;
	}

	public void setPedido_logix(Integer pedido_logix) {
		this.pedido_logix = pedido_logix;
	}

	public String getSituacao() {
		return situacao;
	}

	public void setSituacao(String situacao) {
		this.situacao = situacao;
	}

	public String getPedido_bloqueado() {
		return pedido_bloqueado;
	}

	public void setPedido_bloqueado(String pedido_bloqueado) {
		this.pedido_bloqueado = pedido_bloqueado;
	}

	public String getTipo_frete() {
		return tipo_frete;
	}

	public void setTipo_frete(String tipo_frete) {
		this.tipo_frete = tipo_frete;
	}


}
