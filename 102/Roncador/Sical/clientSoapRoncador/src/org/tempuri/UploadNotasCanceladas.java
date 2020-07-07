/**
 * UploadNotasCanceladas.java
 *
 * This file was auto-generated from WSDL
 * by the Apache Axis 1.4 Apr 22, 2006 (06:55:48 PDT) WSDL2Java emitter.
 */

package org.tempuri;

public class UploadNotasCanceladas  implements java.io.Serializable {
    private java.lang.String strCNPJ;

    private java.lang.String strSenha;

    private org.tempuri.UploadNotasCanceladasDsNotasCanc dsNotasCanc;

    public UploadNotasCanceladas() {
    }

    public UploadNotasCanceladas(
           java.lang.String strCNPJ,
           java.lang.String strSenha,
           org.tempuri.UploadNotasCanceladasDsNotasCanc dsNotasCanc) {
           this.strCNPJ = strCNPJ;
           this.strSenha = strSenha;
           this.dsNotasCanc = dsNotasCanc;
    }


    /**
     * Gets the strCNPJ value for this UploadNotasCanceladas.
     * 
     * @return strCNPJ
     */
    public java.lang.String getStrCNPJ() {
        return strCNPJ;
    }


    /**
     * Sets the strCNPJ value for this UploadNotasCanceladas.
     * 
     * @param strCNPJ
     */
    public void setStrCNPJ(java.lang.String strCNPJ) {
        this.strCNPJ = strCNPJ;
    }


    /**
     * Gets the strSenha value for this UploadNotasCanceladas.
     * 
     * @return strSenha
     */
    public java.lang.String getStrSenha() {
        return strSenha;
    }


    /**
     * Sets the strSenha value for this UploadNotasCanceladas.
     * 
     * @param strSenha
     */
    public void setStrSenha(java.lang.String strSenha) {
        this.strSenha = strSenha;
    }


    /**
     * Gets the dsNotasCanc value for this UploadNotasCanceladas.
     * 
     * @return dsNotasCanc
     */
    public org.tempuri.UploadNotasCanceladasDsNotasCanc getDsNotasCanc() {
        return dsNotasCanc;
    }


    /**
     * Sets the dsNotasCanc value for this UploadNotasCanceladas.
     * 
     * @param dsNotasCanc
     */
    public void setDsNotasCanc(org.tempuri.UploadNotasCanceladasDsNotasCanc dsNotasCanc) {
        this.dsNotasCanc = dsNotasCanc;
    }

    private java.lang.Object __equalsCalc = null;
    public synchronized boolean equals(java.lang.Object obj) {
        if (!(obj instanceof UploadNotasCanceladas)) return false;
        UploadNotasCanceladas other = (UploadNotasCanceladas) obj;
        if (obj == null) return false;
        if (this == obj) return true;
        if (__equalsCalc != null) {
            return (__equalsCalc == obj);
        }
        __equalsCalc = obj;
        boolean _equals;
        _equals = true && 
            ((this.strCNPJ==null && other.getStrCNPJ()==null) || 
             (this.strCNPJ!=null &&
              this.strCNPJ.equals(other.getStrCNPJ()))) &&
            ((this.strSenha==null && other.getStrSenha()==null) || 
             (this.strSenha!=null &&
              this.strSenha.equals(other.getStrSenha()))) &&
            ((this.dsNotasCanc==null && other.getDsNotasCanc()==null) || 
             (this.dsNotasCanc!=null &&
              this.dsNotasCanc.equals(other.getDsNotasCanc())));
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
        if (getStrCNPJ() != null) {
            _hashCode += getStrCNPJ().hashCode();
        }
        if (getStrSenha() != null) {
            _hashCode += getStrSenha().hashCode();
        }
        if (getDsNotasCanc() != null) {
            _hashCode += getDsNotasCanc().hashCode();
        }
        __hashCodeCalc = false;
        return _hashCode;
    }

    // Type metadata
    private static org.apache.axis.description.TypeDesc typeDesc =
        new org.apache.axis.description.TypeDesc(UploadNotasCanceladas.class, true);

    static {
        typeDesc.setXmlType(new javax.xml.namespace.QName("http://tempuri.org/", ">UploadNotasCanceladas"));
        org.apache.axis.description.ElementDesc elemField = new org.apache.axis.description.ElementDesc();
        elemField.setFieldName("strCNPJ");
        elemField.setXmlName(new javax.xml.namespace.QName("http://tempuri.org/", "strCNPJ"));
        elemField.setXmlType(new javax.xml.namespace.QName("http://www.w3.org/2001/XMLSchema", "string"));
        elemField.setMinOccurs(0);
        elemField.setNillable(false);
        typeDesc.addFieldDesc(elemField);
        elemField = new org.apache.axis.description.ElementDesc();
        elemField.setFieldName("strSenha");
        elemField.setXmlName(new javax.xml.namespace.QName("http://tempuri.org/", "strSenha"));
        elemField.setXmlType(new javax.xml.namespace.QName("http://www.w3.org/2001/XMLSchema", "string"));
        elemField.setMinOccurs(0);
        elemField.setNillable(false);
        typeDesc.addFieldDesc(elemField);
        elemField = new org.apache.axis.description.ElementDesc();
        elemField.setFieldName("dsNotasCanc");
        elemField.setXmlName(new javax.xml.namespace.QName("http://tempuri.org/", "dsNotasCanc"));
        elemField.setXmlType(new javax.xml.namespace.QName("http://tempuri.org/", ">>UploadNotasCanceladas>dsNotasCanc"));
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
