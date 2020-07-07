package br.com.SGIURD.form;


public class PaisesForm extends AuditoriaForm{
	/**
	 * 
	 */
	private static final long serialVersionUID = 1L;	
		
	private int acao, cod_modulo;

	private String cod_pais, den_pais, cod_ddi, for_data, pais;

	public int getAcao() {
		return acao;
	}

	public void setAcao(int acao) {
		this.acao = acao;
	}

	public int getCod_modulo() {
		return cod_modulo;
	}

	public void setCod_modulo(int cod_modulo) {
		this.cod_modulo = cod_modulo;
	}

	public String getCod_pais() {
		return cod_pais;
	}

	public void setCod_pais(String cod_pais) {
		this.cod_pais = cod_pais;
	}

	public String getDen_pais() {
		return den_pais;
	}

	public void setDen_pais(String den_pais) {
		this.den_pais = den_pais;
	}

	public String getCod_ddi() {
		return cod_ddi;
	}

	public void setCod_ddi(String cod_ddi) {
		this.cod_ddi = cod_ddi;
	}

	public String getFor_data() {
		return for_data;
	}

	public void setFor_data(String for_data) {
		this.for_data = for_data;
	}

	public String getPais() {
		return pais;
	}

	public void setPais(String pais) {
		this.pais = pais;
	}



}
