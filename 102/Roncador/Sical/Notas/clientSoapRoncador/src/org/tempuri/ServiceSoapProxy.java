package org.tempuri;

public class ServiceSoapProxy implements org.tempuri.ServiceSoap {
  private String _endpoint = null;
  private org.tempuri.ServiceSoap serviceSoap = null;
  
  public ServiceSoapProxy() {
    _initServiceSoapProxy();
  }
  
  public ServiceSoapProxy(String endpoint) {
    _endpoint = endpoint;
    _initServiceSoapProxy();
  }
  
  private void _initServiceSoapProxy() {
    try {
      serviceSoap = (new org.tempuri.ServiceLocator()).getServiceSoap();
      if (serviceSoap != null) {
        if (_endpoint != null)
          ((javax.xml.rpc.Stub)serviceSoap)._setProperty("javax.xml.rpc.service.endpoint.address", _endpoint);
        else
          _endpoint = (String)((javax.xml.rpc.Stub)serviceSoap)._getProperty("javax.xml.rpc.service.endpoint.address");
      }
      
    }
    catch (javax.xml.rpc.ServiceException serviceException) {}
  }
  
  public String getEndpoint() {
    return _endpoint;
  }
  
  public void setEndpoint(String endpoint) {
    _endpoint = endpoint;
    if (serviceSoap != null)
      ((javax.xml.rpc.Stub)serviceSoap)._setProperty("javax.xml.rpc.service.endpoint.address", _endpoint);
    
  }
  
  public org.tempuri.ServiceSoap getServiceSoap() {
    if (serviceSoap == null)
      _initServiceSoapProxy();
    return serviceSoap;
  }
  
  public org.tempuri.DownloadPedidosResponseDownloadPedidosResult downloadPedidos(java.lang.String strCNPJ, java.lang.String strSenha) throws java.rmi.RemoteException{
    if (serviceSoap == null)
      _initServiceSoapProxy();
    return serviceSoap.downloadPedidos(strCNPJ, strSenha);
  }
  
  public org.tempuri.DownloadAdiantamentosClientesResponseDownloadAdiantamentosClientesResult downloadAdiantamentosClientes(java.lang.String strCNPJ, java.lang.String strSenha, java.util.Calendar dataCreditoInicial, java.util.Calendar dataCreditoFinal) throws java.rmi.RemoteException{
    if (serviceSoap == null)
      _initServiceSoapProxy();
    return serviceSoap.downloadAdiantamentosClientes(strCNPJ, strSenha, dataCreditoInicial, dataCreditoFinal);
  }
  
  public org.tempuri.UploadNotasResponseUploadNotasResult uploadNotas(java.lang.String strCNPJ, java.lang.String strSenha, org.tempuri.UploadNotasDsNotas dsNotas) throws java.rmi.RemoteException{
    if (serviceSoap == null)
      _initServiceSoapProxy();
    return serviceSoap.uploadNotas(strCNPJ, strSenha, dsNotas);
  }
  
  public org.tempuri.UploadNotasCanceladasResponseUploadNotasCanceladasResult uploadNotasCanceladas(java.lang.String strCNPJ, java.lang.String strSenha, org.tempuri.UploadNotasCanceladasDsNotasCanc dsNotasCanc) throws java.rmi.RemoteException{
    if (serviceSoap == null)
      _initServiceSoapProxy();
    return serviceSoap.uploadNotasCanceladas(strCNPJ, strSenha, dsNotasCanc);
  }
  
  public java.lang.String uploadNotasNOVO(java.lang.String strCNPJ, java.lang.String strSenha, java.lang.String xmlData) throws java.rmi.RemoteException{
    if (serviceSoap == null)
      _initServiceSoapProxy();
    return serviceSoap.uploadNotasNOVO(strCNPJ, strSenha, xmlData);
  }
  
  public java.lang.String uploadNotasCanceladasNOVO(java.lang.String strCNPJ, java.lang.String strSenha, java.lang.String xmlData) throws java.rmi.RemoteException{
    if (serviceSoap == null)
      _initServiceSoapProxy();
    return serviceSoap.uploadNotasCanceladasNOVO(strCNPJ, strSenha, xmlData);
  }
  
  
}