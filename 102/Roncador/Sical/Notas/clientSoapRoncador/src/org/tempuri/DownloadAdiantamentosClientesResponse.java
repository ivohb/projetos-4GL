/**
 * DownloadAdiantamentosClientesResponse.java
 *
 * This file was auto-generated from WSDL
 * by the Apache Axis 1.4 Apr 22, 2006 (06:55:48 PDT) WSDL2Java emitter.
 */

package org.tempuri;

public class DownloadAdiantamentosClientesResponse  implements java.io.Serializable {
    private org.tempuri.DownloadAdiantamentosClientesResponseDownloadAdiantamentosClientesResult downloadAdiantamentosClientesResult;

    public DownloadAdiantamentosClientesResponse() {
    }

    public DownloadAdiantamentosClientesResponse(
           org.tempuri.DownloadAdiantamentosClientesResponseDownloadAdiantamentosClientesResult downloadAdiantamentosClientesResult) {
           this.downloadAdiantamentosClientesResult = downloadAdiantamentosClientesResult;
    }


    /**
     * Gets the downloadAdiantamentosClientesResult value for this DownloadAdiantamentosClientesResponse.
     * 
     * @return downloadAdiantamentosClientesResult
     */
    public org.tempuri.DownloadAdiantamentosClientesResponseDownloadAdiantamentosClientesResult getDownloadAdiantamentosClientesResult() {
        return downloadAdiantamentosClientesResult;
    }


    /**
     * Sets the downloadAdiantamentosClientesResult value for this DownloadAdiantamentosClientesResponse.
     * 
     * @param downloadAdiantamentosClientesResult
     */
    public void setDownloadAdiantamentosClientesResult(org.tempuri.DownloadAdiantamentosClientesResponseDownloadAdiantamentosClientesResult downloadAdiantamentosClientesResult) {
        this.downloadAdiantamentosClientesResult = downloadAdiantamentosClientesResult;
    }

    private java.lang.Object __equalsCalc = null;
    public synchronized boolean equals(java.lang.Object obj) {
        if (!(obj instanceof DownloadAdiantamentosClientesResponse)) return false;
        DownloadAdiantamentosClientesResponse other = (DownloadAdiantamentosClientesResponse) obj;
        if (obj == null) return false;
        if (this == obj) return true;
        if (__equalsCalc != null) {
            return (__equalsCalc == obj);
        }
        __equalsCalc = obj;
        boolean _equals;
        _equals = true && 
            ((this.downloadAdiantamentosClientesResult==null && other.getDownloadAdiantamentosClientesResult()==null) || 
             (this.downloadAdiantamentosClientesResult!=null &&
              this.downloadAdiantamentosClientesResult.equals(other.getDownloadAdiantamentosClientesResult())));
        __equalsCalc = null;
        return _equals;
    }

    private boolean __hashCodeCalc = false;
    public synchronized int hashCode() {
        if (__hashCodeCalc) {
            return 0;
        }
        __hashCodeCalc = true;
        int _hashCode = 1;
        if (getDownloadAdiantamentosClientesResult() != null) {
            _hashCode += getDownloadAdiantamentosClientesResult().hashCode();
        }
        __hashCodeCalc = false;
        return _hashCode;
    }

    // Type metadata
    private static org.apache.axis.description.TypeDesc typeDesc =
        new org.apache.axis.description.TypeDesc(DownloadAdiantamentosClientesResponse.class, true);

    static {
        typeDesc.setXmlType(new javax.xml.namespace.QName("http://tempuri.org/", ">DownloadAdiantamentosClientesResponse"));
        org.apache.axis.description.ElementDesc elemField = new org.apache.axis.description.ElementDesc();
        elemField.setFieldName("downloadAdiantamentosClientesResult");
        elemField.setXmlName(new javax.xml.namespace.QName("http://tempuri.org/", "DownloadAdiantamentosClientesResult"));
        elemField.setXmlType(new javax.xml.namespace.QName("http://tempuri.org/", ">>DownloadAdiantamentosClientesResponse>DownloadAdiantamentosClientesResult"));
        elemField.setMinOccurs(0);
        elemField.setNillable(false);
        typeDesc.addFieldDesc(elemField);
    }

    /**
     * Return type metadata object
     */
    public static org.apache.axis.description.TypeDesc getTypeDesc() {
        return typeDesc;
    }

    /**
     * Get Custom Serializer
     */
    public static org.apache.axis.encoding.Serializer getSerializer(
           java.lang.String mechType, 
           java.lang.Class _javaType,  
           javax.xml.namespace.QName _xmlType) {
        return 
          new  org.apache.axis.encoding.ser.BeanSerializer(
            _javaType, _xmlType, typeDesc);
    }

    /**
     * Get Custom Deserializer
     */
    public static org.apache.axis.encoding.Deserializer getDeserializer(
           java.lang.String mechType, 
           java.lang.Class _javaType,  
           javax.xml.namespace.QName _xmlType) {
        return 
          new  org.apache.axis.encoding.ser.BeanDeserializer(
            _javaType, _xmlType, typeDesc);
    }

}
