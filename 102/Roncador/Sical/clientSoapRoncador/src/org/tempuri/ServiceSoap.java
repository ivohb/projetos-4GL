/**
 * ServiceSoap.java
 *
 * This file was auto-generated from WSDL
 * by the Apache Axis 1.4 Apr 22, 2006 (06:55:48 PDT) WSDL2Java emitter.
 */

package org.tempuri;

public interface ServiceSoap extends java.rmi.Remote {
    public org.tempuri.DownloadPedidosResponseDownloadPedidosResult downloadPedidos(java.lang.String strCNPJ, java.lang.String strSenha) throws java.rmi.RemoteException;
    public org.tempuri.DownloadAdiantamentosClientesResponseDownloadAdiantamentosClientesResult downloadAdiantamentosClientes(java.lang.String strCNPJ, java.lang.String strSenha, java.util.Calendar dataCreditoInicial, java.util.Calendar dataCreditoFinal) throws java.rmi.RemoteException;
    public org.tempuri.UploadNotasResponseUploadNotasResult uploadNotas(java.lang.String strCNPJ, java.lang.String strSenha, org.tempuri.UploadNotasDsNotas dsNotas) throws java.rmi.RemoteException;
    public org.tempuri.UploadNotasCanceladasResponseUploadNotasCanceladasResult uploadNotasCanceladas(java.lang.String strCNPJ, java.lang.String strSenha, org.tempuri.UploadNotasCanceladasDsNotasCanc dsNotasCanc) throws java.rmi.RemoteException;
    public java.lang.String uploadNotasNOVO(java.lang.String strCNPJ, java.lang.String strSenha, java.lang.String xmlData) throws java.rmi.RemoteException;
    public java.lang.String uploadNotasCanceladasNOVO(java.lang.String strCNPJ, java.lang.String strSenha, java.lang.String xmlData) throws java.rmi.RemoteException;
}
