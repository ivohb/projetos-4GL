package main.java.com.aceex.roncador.model;

import java.io.Serializable;

public class CliCanalVenda implements Serializable {
	private static final long serialVersionUID = 1L;

	private Integer codNivel1;
	private Integer codNivel2;
	private Integer codNivel3;
	private String iesNivel;
	private String codTipCarteira;
	
	public CliCanalVenda() {}

	public Integer getCodNivel1() {
		return codNivel1;
	}

	public void setCodNivel1(Integer codNivel1) {
		this.codNivel1 = codNivel1;
	}

	public Integer getCodNivel2() {
		return codNivel2;
	}

	public void setCodNivel2(Integer codNivel2) {
		this.codNivel2 = codNivel2;
	}

	public Integer getCodNivel3() {
		return codNivel3;
	}

	public void setCodNivel3(Integer codNivel3) {
		this.codNivel3 = codNivel3;
	}

	public String getIesNivel() {
		return iesNivel;
	}

	public void setIesNivel(String iesNivel) {
		this.iesNivel = iesNivel;
	}

	public String getCodTipCarteira() {
		return codTipCarteira;
	}

	public void setCodTipCarteira(String codTipCarteira) {
		this.codTipCarteira = codTipCarteira;
	}
		
}
