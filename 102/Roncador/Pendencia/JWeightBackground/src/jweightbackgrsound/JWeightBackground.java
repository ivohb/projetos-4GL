package jweightbackgrsound;

import java.io.BufferedInputStream;
import java.io.FileWriter;
import java.io.IOException;
import java.io.InputStream;
import java.io.OutputStream;
import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;
import java.text.DateFormat;
import java.text.SimpleDateFormat;
import java.util.Calendar;
import java.util.Date;
import java.util.Enumeration;
import java.util.logging.Level;
import java.util.logging.Logger;

import javax.comm.CommPortIdentifier;
import javax.comm.NoSuchPortException;
import javax.comm.PortInUseException;
import javax.comm.SerialPort;
import javax.comm.UnsupportedCommOperationException;

//public class JWeightBackground implements SerialPortEventListener, Runnable {

public class JWeightBackground   {

	public Enumeration listaDePortas;
	public String strPortas[];
	public SerialPort serPort;
	public CommPortIdentifier cpId;
	public FileWriter fw;
	public String strPorta;
	public String strDadosLidos;
	public int iNroBytes;
	public int iBaudrate;
	public int iTimeOut;
	public CommPortIdentifier cpIdent;
	//public SerialPort serPorta;
	public OutputStream outSaida;
	public InputStream inpEntrada;
	public Thread thrLeitura;
	public boolean bPortaIs;
	public boolean bPortaOpen;
	public boolean bLeitura;
	public boolean bEscrita;
	public ConexaoBanco dadosCon;
	public Connection link;
	public Statement stm;
	public Statement stm2;
	public Statement stmCommit;
	public DateFormat dataFormat;
	public Date data;
	public String codigoEmpresa = "";
	public String codigoBalanca = "";
	public String geraLog = "S";
	public String sinalString = "+";

	public JWeightBackground() {
		dataFormat = new SimpleDateFormat("dd/MM/yyy h:m:s");
	}

	public static void main(String args[]) {
		if(args.length < 2){
    	    System.out.println(" Não foi possível executar. É necessário informar o codigo da empresa e codigo da balança.");	
    	    System.exit(0);
    	}else{
    		JWeightBackground app = new JWeightBackground();
    		String log = "S";
    		try{
    			log	 = args[2];
    			if(log == null) log = "";
    			if(log.trim().equals("")){
    				log = "S";
    			}
    		}catch (Exception e) {}
    		
    		String sinal = "+";
    		try{
    			sinal	 = args[3];
    			if(sinal == null) sinal = "";
    			if(sinal.trim().equals("")){
    				sinal = "+";
    			}
    		}catch (Exception e) {}
    		
    		app.start(args[0], args[1], log, sinal);
        }
	}

	public void start(String param1, String param2, String param3, String param4) {
	    this.codigoEmpresa = param1;
	   	this.codigoBalanca = param2;
	   	this.geraLog = param3;
	   	this.sinalString = param4;
		criarArquivo();
		lerConfig();
		changePortQuery();
		listarPortas();
		habilitarLeitura();
		getPortaID();
		conectarPorta();
		lerDados();
	}

	public void lerConfig() {
		strPorta = "COM1"; // Coloca como padrao
		iBaudrate = 4800;
		iTimeOut = 1000;
		
		
		//Busca na tabela os dados da porta
	    String strQuery = "SELECT * FROM logix.esp_par_balanca WHERE cod_empresa = '"+this.codigoEmpresa+"' AND cod_balanca = '"+this.codigoBalanca+"'";
	    //System.out.println("Executando a query : "+strQuery);
	    conectarBanco();
        escreverArquivo("Buscando dados da empresa: "+this.codigoEmpresa+" e da balança : "+this.codigoBalanca  );
        PreparedStatement pstm = null;
        ResultSet rsDados = null;
        try {
            pstm = link.prepareStatement(strQuery);
            rsDados = pstm.executeQuery();
            
            if(rsDados.next()){
            	 strPorta = rsDados.getString("porta");
            	 if (strPorta == null){
            		 strPorta = "";
            	 }
            	 strPorta = strPorta.trim();
            	 //String strTimeOut = rsDados.getString("time_out");
                 //iTimeOut = Integer.parseInt(strTimeOut.trim());
                 escreverArquivo("Dados carregados com sucesso");
            }else{
            	 escreverArquivo("Dados não encontrado");
            }
            
           
            
        } catch (Exception ex) {
            Logger.getLogger(JWeightBackground.class.getName()).log(Level.SEVERE, null, ex);
            escreverArquivo("Erro ao buscar os dados na tabela esp_par_balanca: "+ex);
            //System.out.println("Erro ao buscar os dados na tabela esp_par_balanca: "+ex);
            //ex.printStackTrace();
        }
        finally{
        	try{
        		pstm.close();
        		pstm = null;
        		rsDados.close();
        		rsDados = null;
        	}catch (Exception e) {}
        }
		
		
	}

	public void criarArquivo() {
		try {
			if(this.geraLog.equals("S")){
				fw = new FileWriter(
						"\\totvs\\logix\\bin\\smartclient\\visio\\erro_porta_bal"+this.codigoBalanca+".txt",
						true);
				fw.close();
			}
		} catch (IOException ex) {
			Logger.getLogger(JWeightBackground.class.getName()).log(Level.SEVERE, null, ex);
		}
	}

	public void escreverArquivo(String strMsg) {
		try {
			if(this.geraLog.equals("S")){
				fw = new FileWriter(
						"\\totvs\\logix\\bin\\smartclient\\visio\\erro_porta_bal"+this.codigoBalanca+".txt",
						true);
				data = new Date();
				fw.write((new StringBuilder()).append(dataFormat.format(data))
						.append(" - ").append(strMsg).toString());
				fw.write("\r\n");
				fw.close();
			}
		} catch (IOException ex) {
			Logger.getLogger(JWeightBackground.class.getName()).log(Level.SEVERE, null, ex);
		}
	}

	public void changePortQuery() {
		String strResult = new String();
		escreverArquivo("Enviando comando change port /query . . .");
		try {
			Process p = Runtime.getRuntime().exec("change port /query");
			InputStream input = new BufferedInputStream(p.getInputStream());
			StringBuffer strBuf = new StringBuffer();
			do {
				int c = input.read();
				if (c == -1)
					break;
				strBuf.append((char) c);
				strResult = strBuf.toString();
			} while (true);
			escreverArquivo(strResult);
		} catch (IOException ex) {
			Logger.getLogger(JWeightBackground.class.getName()).log(Level.SEVERE, null, ex);
		}
	}

	public void listarPortas() {
		escreverArquivo("Procurando pelas portas seriais");
		listaDePortas = CommPortIdentifier.getPortIdentifiers();
		int i = 0;
		strPortas = new String[99];
		while (listaDePortas.hasMoreElements()) {
			CommPortIdentifier comPort = (CommPortIdentifier) listaDePortas
					.nextElement();
			strPortas[i] = comPort.getName();
			escreverArquivo((new StringBuilder()).append("Porta encontrada: ")
					.append(strPortas[i]).toString());
			i++;
		}
	}

	public void abrirPorta() {
		escreverArquivo("Conectando-se a porta "+this.strPorta);
		try {
			cpId = CommPortIdentifier.getPortIdentifier(this.strPorta);
			serPort = (SerialPort) cpId.open("Pesagem"+this.codigoBalanca, 1000);
			escreverArquivo("Conexão estabelecida com a porta "+this.strPorta);
		} catch (NoSuchPortException ex) {
			Logger.getLogger(JWeightBackground.class.getName()).log(Level.SEVERE, null, ex);
		} catch (PortInUseException ex) {
			Logger.getLogger(JWeightBackground.class.getName()).log(Level.SEVERE, null, ex);
		}
	}

	public void habilitarEscrita() {
		bEscrita = true;
		bLeitura = false;
	}

	public void habilitarLeitura() {
		escreverArquivo("Habilitando opção de leitura");
		bLeitura = true;
		bEscrita = false;
	}

	public void getPortaID() {
		escreverArquivo("Verificando disponibilidade da porta "+strPorta);
		try {
			cpIdent = CommPortIdentifier.getPortIdentifier(strPorta);
			if (cpIdent == null) {
				escreverArquivo((new StringBuilder()).append("A porta ")
						.append(strPorta)
						.append(" não está disponível").toString());
				bPortaIs = false;
			} else {
				escreverArquivo((new StringBuilder()).append("A porta ")
						.append(strPorta).append(" está disponível")
						.toString());
			}
			bPortaIs = true;
		} catch (NoSuchPortException ex) {
			escreverArquivo((new StringBuilder()).append("A porta ")
					.append(strPorta).append(" não está disponível")
					.toString());
			escreverArquivo(ex.toString());
		}
	}

	public void conectarPorta() {
		escreverArquivo("Conectando - se a porta "+this.strPorta);
		try {
			//Calendar calendar = Calendar.getInstance();
			//serPorta = (SerialPort) cpIdent.open("JWeightBackground_"+calendar.getTimeInMillis(), iTimeOut);
			
			//cpId = CommPortIdentifier.getPortIdentifier(this.strPorta);
			serPort = (SerialPort) cpIdent.open("Pesagem"+this.codigoBalanca, 1000);
			
			bPortaIs = true;
			//SerialPort _tmp = serPorta;
			//SerialPort _tmp1 = serPorta;
			//SerialPort _tmp2 = serPorta;
			serPort.setSerialPortParams(iBaudrate, 7, 1, 2);
			escreverArquivo("Conexão a porta "+this.strPorta+" efetuada com sucesso");
		} catch (NullPointerException ex) {
			escreverArquivo("Falha de conexão com a porta "+this.strPorta);
			escreverArquivo("Motivo da Falha de conexão com a porta "+this.strPorta+": ");
			escreverArquivo(ex.toString());
			 desconectarPorta();
		} catch (PortInUseException ex) {
			escreverArquivo("Falha de conexão com a porta "+this.strPorta);
			escreverArquivo("Motivo da Falha de conexão com a porta "+this.strPorta+": ");
			escreverArquivo(ex.toString());
			ex.printStackTrace();
			bPortaIs = false;
			desconectarPorta();
			
		} catch (UnsupportedCommOperationException ex) {
			escreverArquivo("Falha de conexão com a porta "+this.strPorta);
			escreverArquivo("Motivo da Falha de conexão com a porta "+this.strPorta+": ");
			escreverArquivo(ex.toString());
			bPortaIs = false;
			 desconectarPorta();
		}
	}

	public void lerDados() {
		escreverArquivo("Verificando fluxo de dados da porta "+this.strPorta);
		System.out.println("Verificando fluxo de dados...");
		if (bLeitura) {
			try {
				inpEntrada = serPort.getInputStream();
				escreverArquivo("Fluxo de dados da porta "+this.strPorta+" ok");
				serialEvent();
			} catch (IOException ex) {
				escreverArquivo("Não há fluxo de dados da porta "+this.strPorta);
				desconectarPorta();
			}
			//try {
				//serPorta.addEventListener(this);
			//} catch (TooManyListenersException ex) {
			//}
			//serPorta.notifyOnDataAvailable(true);
			//thrLeitura = new Thread(this);
			//thrLeitura.start();
		}
	}

	public void serialEvent() {
		escreverArquivo("Iniciando leitura de dados da porta "+this.strPorta);
		//int c = 0;
		//boolean bGravou = false;
		//switch (ev.getEventType()) {
		//case 1: // '\001'
			byte bBufferLeitura[] = new byte[1024];
			//while (c < 100){
				try {
					while (inpEntrada.available() > 0)
						iNroBytes = inpEntrada.read(bBufferLeitura);
					String strDadosLidos = new String(bBufferLeitura);
					if (bBufferLeitura.length == 0) {
						escreverArquivo("0 bytes recebidos");
						//continue;
					}
					escreverArquivo((new StringBuilder())
							.append("String recebida da balança: ")
							.append(strDadosLidos).toString());
					double dValPeso = converterValor(strDadosLidos);
					
					if(strDadosLidos == null){
						strDadosLidos = "";
					}
					if(strDadosLidos.trim().equals("")){
						dValPeso = 0;
					}
					
					if (dValPeso >= 0) {
						gravarPesagem(dValPeso);
						desconectarPorta();
						System.exit(0);
					}
					
					
					
					//continue;
				} catch (Exception e) {
					escreverArquivo("Erro na leitura de dados da porta "+this.strPorta);
					escreverArquivo((new StringBuilder())
							.append("Motivo do erro: ").append(e).toString());
					//c++;
				}
			//}
			desconectarPorta();
			//break;
		//}
	}

	public double converterValor(String strValor) {
		double dValPeso = 0;
		int posIni = 0;
		int posFim = 0;
		if (strValor.indexOf(this.sinalString) >= 0) {
			
			// Tentando evitar a sujeira no valor recebido
			
				posIni = strValor.indexOf(this.sinalString);
				
				if(posIni < 0){
					posIni = 0;
				}
				
				posIni++;
				posFim = posIni + 7;
				
				
				
				for(int i = 0 ; i < strValor.length(); i++){
				 try{
					
					strValor = strValor.substring(posIni, posFim);
					dValPeso = Double.parseDouble(strValor);
					
					escreverArquivo((new StringBuilder()).append("pos ini: ")
							.append(posIni).append(" pos fim: ").append(posFim)
							.toString());
					escreverArquivo((new StringBuilder()).append("string convertida: ")
							.append(strValor).toString());
					escreverArquivo((new StringBuilder()).append("valor double: ")
							.append(dValPeso).toString());
					
					i = strValor.length();
					
				  }catch (Exception e) {posIni = posIni+1; posFim = posFim+1; }
				}
		}
		return dValPeso;
	}

	public void desconectarPorta() {
		escreverArquivo("Fechando conexão com a porta "+this.strPorta);
		try {
			serPort.close();
			
			escreverArquivo("Conexão com a porta serial fechada");
			
		} catch (Exception e) {
			escreverArquivo("Erro ao descontar porta seria, motivo do erro:");
			escreverArquivo((new StringBuilder()).append(" ").append(e)
					.toString());
		}
		finally{
			try{
				link.close();
			}catch (Exception e) {
				// TODO: handle exception
			}
		}
	}

	public void gravarPesagem(double dValPeso) {
		String strCommit = new String("COMMIT");
		String strQuery = new String(
				"DELETE FROM logix.tran_arg WHERE cod_empresa = '"+this.codigoEmpresa+"' AND num_programa = 'JAVA"+this.codigoBalanca+"' ");
		String strQuery2 = new String(
				(new StringBuilder())
						.append("INSERT INTO logix.tran_arg ( cod_empresa, num_programa, login_usuario, data_proc, hora_proc, num_arg, indice_arg, arg_ies, arg_txt, arg_val, arg_num, arg_data) VALUES ( '"+this.codigoEmpresa+"', 'JAVA"+this.codigoBalanca+"', 'jweight', SYSDATE, SYSDATE,  1, 1, '',  'SP1',   '',  ")
						.append(dValPeso).append(", ").append("'') ")
						.toString());
		String strQuery3 = new String(
				(new StringBuilder())
						.append("INSERT INTO logix.tran_arg ( cod_empresa, num_programa, login_usuario, data_proc, hora_proc, num_arg, indice_arg, arg_ies, arg_txt, arg_val, arg_num, arg_data) VALUES ( '"+this.codigoEmpresa+"', 'JAVA"+this.codigoBalanca+"', 'jweight', TO_DATE('1900/01/01', 'yyyy/mm/dd'), TO_DATE('1900/01/01 00:00:00', 'yyyy/mm/dd hh24:mi:ss'),  1, 1, '',  'SP1',   '',  ")
						.append(dValPeso).append(", ").append("'') ")
						.toString());
		conectarBanco();
		escreverArquivo("Gravando pesagem na tabela tran_arg");
		try {
			stm = link.createStatement();
			stm.execute(strQuery);
			stmCommit = link.createStatement();
			stmCommit.execute(strCommit);
			stm2 = link.createStatement();
			stm2.execute(strQuery2);
			stmCommit.execute(strCommit);
			escreverArquivo("Pesagem salva com sucesso");
			stm.close();
			stm2.close();
			link.close();
		} catch (SQLException ex) {
			Logger.getLogger(JWeightBackground.class.getName()).log(Level.SEVERE, null, ex);
			escreverArquivo((new StringBuilder())
					.append("Erro ao inserir dados na tabela tran_arg: ")
					.append(ex).toString());
		}
	}

	//public void run() {
		//try {
		//	Thread.sleep(5000L);
		//} catch (InterruptedException ex) {
			//Logger.getLogger(JWeightBackground.class.getName()).log(Level.SEVERE, null, ex);
		//}
	//}

	public void conectarBanco() {
		
		try {
			serPort.close();
		} catch (Exception e) {}
		
		
		if(link == null){
			escreverArquivo("Conectando-se a base de dados . . .");
			dadosCon = new ConexaoBanco();
			try {
				Class.forName(dadosCon.driver);
				link = DriverManager.getConnection(dadosCon.url, dadosCon.usuario,
						dadosCon.senha);
				escreverArquivo("Conectado a base de dados com sucesso.");
			} catch (ClassNotFoundException ex) {
				escreverArquivo("Erro ao conectar-se com a base de dados");
				Logger.getLogger(JWeightBackground.class.getName()).log(Level.SEVERE, null, ex);
			} catch (SQLException ex) {
				escreverArquivo("Erro ao conectar-se com a base de dados");
				Logger.getLogger(JWeightBackground.class.getName()).log(Level.SEVERE, null, ex);
			}
		}
	}

}
