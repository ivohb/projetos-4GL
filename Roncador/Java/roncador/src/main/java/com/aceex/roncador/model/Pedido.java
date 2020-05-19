package main.java.com.aceex.roncador.model;

import java.io.Serializable;

public class Pedido implements Serializable {
	private static final long serialVersionUID = 1L;

	private String codEmpresa;
	private Integer numPedido;
	private String codCliente;
	private Double pctComissao;
	private String numPedRepres;
	private String datEmisRepres;
	private Integer codNatOper;
	private String codTranspor;
	private String codConsig;
	private Integer iesFinalidade;
	private Integer iesFrete;
	private String iesPreco;
	private Integer codCndPgto;
	private Double pctDescFinanc;
	private String iesEmbalPadrao;
	private Integer iesTipEntrega;
	private String iesAceite;
	private String iesSitPedido;
	private String datPedido;
	private String numPedidoCli;
	private Double pctDescAdic;
	private Integer numListPreco;
	private Integer codRepres;
	private Integer codRepresAdic;
	private String datAltSit;
	private String datCancel;
	private Integer codTipVenda;
	private Integer codMotivoCan;
	private String datUltFatur;
	private Integer codMoeda;
	private String iesComissao;
	private Double pctFrete;
	private String codTipCarteira;
	private Integer numVersaoLista;
	private String codLocalEstoq;
	private String obsNf;
	private String obsPedido;
	private Integer natOperRemessa;

	public Pedido() { }

	public String getCodEmpresa() {
		return codEmpresa;
	}

	public void setCodEmpresa(String codEmpresa) {
		this.codEmpresa = codEmpresa;
	}

	public Integer getNumPedido() {
		return numPedido;
	}

	public void setNumPedido(Integer numPedido) {
		this.numPedido = numPedido;
	}

	public String getCodCliente() {
		return codCliente;
	}

	public void setCodCliente(String codCliente) {
		this.codCliente = codCliente;
	}

	public Double getPctComissao() {
		return pctComissao;
	}

	public void setPctComissao(Double pctComissao) {
		this.pctComissao = pctComissao;
	}

	public String getNumPedRepres() {
		return numPedRepres;
	}

	public void setNumPedRepres(String numPedRepres) {
		this.numPedRepres = numPedRepres;
	}

	public String getDatEmisRepres() {
		return datEmisRepres;
	}

	public void setDatEmisRepres(String datEmisRepres) {
		this.datEmisRepres = datEmisRepres;
	}

	public Integer getCodNatOper() {
		return codNatOper;
	}

	public void setCodNatOper(Integer codNatOper) {
		this.codNatOper = codNatOper;
	}

	public String getCodTranspor() {
		return codTranspor;
	}

	public void setCodTranspor(String codTranspor) {
		this.codTranspor = codTranspor;
	}

	public String getCodConsig() {
		return codConsig;
	}

	public void setCodConsig(String codConsig) {
		this.codConsig = codConsig;
	}

	public Integer getIesFinalidade() {
		return iesFinalidade;
	}

	public void setIesFinalidade(Integer iesFinalidade) {
		this.iesFinalidade = iesFinalidade;
	}

	public Integer getIesFrete() {
		return iesFrete;
	}

	public void setIesFrete(Integer iesFrete) {
		this.iesFrete = iesFrete;
	}

	public String getIesPreco() {
		return iesPreco;
	}

	public void setIesPreco(String iesPreco) {
		this.iesPreco = iesPreco;
	}

	public Integer getCodCndPgto() {
		return codCndPgto;
	}

	public void setCodCndPgto(Integer codCndPgto) {
		this.codCndPgto = codCndPgto;
	}

	public Double getPctDescFinanc() {
		return pctDescFinanc;
	}

	public void setPctDescFinanc(Double pctDescFinanc) {
		this.pctDescFinanc = pctDescFinanc;
	}

	public String getIesEmbalPadrao() {
		return iesEmbalPadrao;
	}

	public void setIesEmbalPadrao(String iesEmbalPadrao) {
		this.iesEmbalPadrao = iesEmbalPadrao;
	}

	public Integer getIesTipEntrega() {
		return iesTipEntrega;
	}

	public void setIesTipEntrega(Integer iesTipEntrega) {
		this.iesTipEntrega = iesTipEntrega;
	}

	public String getIesAceite() {
		return iesAceite;
	}

	public void setIesAceite(String iesAceite) {
		this.iesAceite = iesAceite;
	}

	public String getIesSitPedido() {
		return iesSitPedido;
	}

	public void setIesSitPedido(String iesSitPedido) {
		this.iesSitPedido = iesSitPedido;
	}

	public String getDatPedido() {
		return datPedido;
	}

	public void setDatPedido(String datPedido) {
		this.datPedido = datPedido;
	}

	public String getNumPedidoCli() {
		return numPedidoCli;
	}

	public void setNumPedidoCli(String numPedidoCli) {
		this.numPedidoCli = numPedidoCli;
	}

	public Double getPctDescAdic() {
		return pctDescAdic;
	}

	public void setPctDescAdic(Double pctDescAdic) {
		this.pctDescAdic = pctDescAdic;
	}

	public Integer getNumListPreco() {
		return numListPreco;
	}

	public void setNumListPreco(Integer numListPreco) {
		this.numListPreco = numListPreco;
	}

	public Integer getCodRepres() {
		return codRepres;
	}

	public void setCodRepres(Integer codRepres) {
		this.codRepres = codRepres;
	}

	public Integer getCodRepresAdic() {
		return codRepresAdic;
	}

	public void setCodRepresAdic(Integer codRepresAdic) {
		this.codRepresAdic = codRepresAdic;
	}

	public String getDatAltSit() {
		return datAltSit;
	}

	public void setDatAltSit(String datAltSit) {
		this.datAltSit = datAltSit;
	}

	public String getDatCancel() {
		return datCancel;
	}

	public void setDatCancel(String datCancel) {
		this.datCancel = datCancel;
	}

	public Integer getCodTipVenda() {
		return codTipVenda;
	}

	public void setCodTipVenda(Integer codTipVenda) {
		this.codTipVenda = codTipVenda;
	}

	public Integer getCodMotivoCan() {
		return codMotivoCan;
	}

	public void setCodMotivoCan(Integer codMotivoCan) {
		this.codMotivoCan = codMotivoCan;
	}

	public String getDatUltFatur() {
		return datUltFatur;
	}

	public void setDatUltFatur(String datUltFatur) {
		this.datUltFatur = datUltFatur;
	}

	public Integer getCodMoeda() {
		return codMoeda;
	}

	public void setCodMoeda(Integer codMoeda) {
		this.codMoeda = codMoeda;
	}

	public String getIesComissao() {
		return iesComissao;
	}

	public void setIesComissao(String iesComissao) {
		this.iesComissao = iesComissao;
	}

	public Double getPctFrete() {
		return pctFrete;
	}

	public void setPctFrete(Double pctFrete) {
		this.pctFrete = pctFrete;
	}

	public String getCodTipCarteira() {
		return codTipCarteira;
	}

	public void setCodTipCarteira(String codTipCarteira) {
		this.codTipCarteira = codTipCarteira;
	}

	public Integer getNumVersaoLista() {
		return numVersaoLista;
	}

	public void setNumVersaoLista(Integer numVersaoLista) {
		this.numVersaoLista = numVersaoLista;
	}

	public String getCodLocalEstoq() {
		return codLocalEstoq;
	}

	public void setCodLocalEstoq(String codLocalEstoq) {
		this.codLocalEstoq = codLocalEstoq;
	}

	public String getObsNf() {
		return obsNf;
	}

	public void setObsNf(String obsNf) {
		this.obsNf = obsNf;
	}

	public String getObsPedido() {
		return obsPedido;
	}

	public void setObsPedido(String obsPedido) {
		this.obsPedido = obsPedido;
	}

	public Integer getNatOperRemessa() {
		return natOperRemessa;
	}

	public void setNatOperRemessa(Integer natOperRemessa) {
		this.natOperRemessa = natOperRemessa;
	}

}
