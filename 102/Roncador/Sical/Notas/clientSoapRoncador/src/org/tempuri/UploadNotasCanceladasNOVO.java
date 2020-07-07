/**
 * UploadNotasCanceladasNOVO.java
 *
 * This file was auto-generated from WSDL
 * by the Apache Axis 1.4 Apr 22, 2006 (06:55:48 PDT) WSDL2Java emitter.
 */

package org.tempuri;

public class UploadNotasCanceladasNOVO  implements java.io.Serializable {
    private java.lang.String strCNPJ;

    private java.lang.String strSenha;

    private java.lang.String xmlData;

    public UploadNotasCanceladasNOVO() {
    }

    public UploadNotasCanceladasNOVO(
           java.lang.String strCNPJ,
           java.lang.String strSenha,
           java.lang.String xmlData) {
           this.strCNPJ = strCNPJ;
           this.strSenha = strSenha;
           this.xmlData = xmlData;
    }


    /**
     * Gets the strCNPJ value for this UploadNotasCanceladasNOVO.
     * 
     * @return strCNPJ
     */
    public java.lang.String getStrCNPJ() {
        return strCNPJ;
    }


    /**
     * Sets the strCNPJ value for this UploadNotasCanceladasNOVO.
     * 
     * @param strCNPJ
     */
    public void setStrCNPJ(java.lang.String strCNPJ) {
        this.strCNPJ = strCNPJ;
    }


    /**
     * Gets the strSenha value for this UploadNotasCanceladasNOVO.
     * 
     * @return strSenha
     */
    public java.lang.String getStrSenha() {
        return strSenha;
    }


    /**
     * Sets the strSenha value for this UploadNotasCanceladasNOVO.
     * 
     * @param strSenha
     */
    public void setStrSenha(java.lang.String strSenha) {
        this.strSenha = strSenha;
    }


    /**
     * Gets the xmlData value for this UploadNotasCanceladasNOVO.
     * 
     * @return xmlData
     */
    public java.lang.String getXmlData() {
        return xmlData;
    }


    /**
     * Sets the xmlData value for this UploadNotasCanceladasNOVO.
     * 
     * @param xmlData
     */
    public void setXmlData(java.lang.String xmlData) {
        this.xmlData = xmlData;
    }

    private java.lang.Object __equalsCalc = null;
    public synchronized boolean equals(java.lang.Object obj) {
        if (!(obj instanceof UploadNotasCanceladasNOVO)) return false;
        UploadNotasCanceladasNOVO other = (UploadNotasCanceladasNOVO) obj;
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
            ((this.xmlData==null && other.getXmlData()==null) || 
             (this.xmlData!=null &&
              this.xmlData.equals(other.getXmlData())));
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
        if (getXmlData() != null) {
            _hashCode += getXmlData().hashCode();
        }
        __hashCodeCalc = false;
        return _hashCode;
    }

    // Type metadata
    private static org.apache.axis.description.TypeDesc typeDesc =
        new org.apache.axis.description.TypeDesc(UploadNotasCanceladasNOVO.class, true);

    static {
        typeDesc.setXmlType(new javax.xml.namespace.QName("http://tempuri.org/", ">UploadNotasCanceladasNOVO"));
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
        elemField.setFieldName("xmlData");
        elemField.setXmlName(new javax.xml.namespace.QName("http://tempuri.org/", "xmlData"));
        elemField.setXmlType(new javax.xml.namespace.QName("http://www.w3.org/2001/XMLSchema", "string"));
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
