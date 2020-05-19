package main.java.com.aceex.roncador.model;

import java.io.Serializable;

public class Parvdp implements Serializable {
	private static final long serialVersionUID = 1L;

	private Integer codMoeda;
	private String parVdpTxt;
	private Integer qtdDiasAtrDupl;
	private Integer qtdDiasAtrMed;
	private Integer numProxPedido;

	public Parvdp() {}

	public Integer getCodMoeda() {
		return codMoeda;
	}

	public void setCodMoeda(Integer codMoeda) {
		this.codMoeda = codMoeda;
	}

	public String getParVdpTxt() {
		return parVdpTxt;
	}

	public void setParVdpTxt(String parVdpTxt) {
		this.parVdpTxt = parVdpTxt;
	}

	public Integer getQtdDiasAtrDupl() {
		return qtdDiasAtrDupl;
	}

	public void setQtdDiasAtrDupl(Integer qtdDiasAtrDupl) {
		this.qtdDiasAtrDupl = qtdDiasAtrDupl;
	}

	public Integer getQtdDiasAtrMed() {
		return qtdDiasAtrMed;
	}

	public void setQtdDiasAtrMed(Integer qtdDiasAtrMed) {
		this.qtdDiasAtrMed = qtdDiasAtrMed;
	}

	public Integer getNumProxPedido() {
		return numProxPedido;
	}

	public void setNumProxPedido(Integer numProxPedido) {
		this.numProxPedido = numProxPedido;
	}
	
	
}
