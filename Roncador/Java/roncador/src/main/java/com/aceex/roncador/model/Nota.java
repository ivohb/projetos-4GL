package main.java.com.aceex.roncador.model;

import java.io.Serializable;
import java.sql.Date;

public class Nota implements Serializable {
	private static final long serialVersionUID = 1L;

	private String empresa;
	private Integer transac;
	private Integer num_nota;
	private String serie ;
	private Integer num_pedido;
	private Date dt_emissao;
	private Integer tipo_operacao;
	private Integer num_nota_origem;
	private String serie_nota_origem;
	private Double quant;
	private String placa_veiculo;
	private String sit_nota;
	
	public Nota() {}

	public String getEmpresa() {
		return empresa;
	}

	public void setEmpresa(String empresa) {
		this.empresa = empresa;
	}

	public Integer getTransac() {
		return transac;
	}

	public void setTransac(Integer transac) {
		this.transac = transac;
	}

	public Integer getNum_nota() {
		return num_nota;
	}

	public void setNum_nota(Integer num_nota) {
		this.num_nota = num_nota;
	}

	public String getSerie() {
		return serie;
	}

	public void setSerie(String serie) {
		this.serie = serie;
	}

	public Integer getNum_pedido() {
		return num_pedido;
	}

	public void setNum_pedido(Integer num_pedido) {
		this.num_pedido = num_pedido;
	}

	public Date getDt_emissao() {
		return dt_emissao;
	}

	public void setDt_emissao(Date dt_emissao) {
		this.dt_emissao = dt_emissao;
	}

	public Integer getTipo_operacao() {
		return tipo_operacao;
	}

	public void setTipo_operacao(Integer tipo_operacao) {
		this.tipo_operacao = tipo_operacao;
	}

	public Integer getNum_nota_origem() {
		return num_nota_origem;
	}

	public void setNum_nota_origem(Integer num_nota_origem) {
		this.num_nota_origem = num_nota_origem;
	}

	public String getSerie_nota_origem() {
		return serie_nota_origem;
	}

	public void setSerie_nota_origem(String serie_nota_origem) {
		this.serie_nota_origem = serie_nota_origem;
	}

	public Double getQuant() {
		return quant;
	}

	public void setQuant(Double quant) {
		this.quant = quant;
	}

	public String getPlaca_veiculo() {
		return placa_veiculo;
	}

	public void setPlaca_veiculo(String placa_veiculo) {
		this.placa_veiculo = placa_veiculo;
	}

	public String getSit_nota() {
		return sit_nota;
	}

	public void setSit_nota(String sit_nota) {
		this.sit_nota = sit_nota;
	}

}

