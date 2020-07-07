/**
 * UploadNotasCanceladasResponse.java
 *
 * This file was auto-generated from WSDL
 * by the Apache Axis 1.4 Apr 22, 2006 (06:55:48 PDT) WSDL2Java emitter.
 */

package org.tempuri;

public class UploadNotasCanceladasResponse  implements java.io.Serializable {
    private org.tempuri.UploadNotasCanceladasResponseUploadNotasCanceladasResult uploadNotasCanceladasResult;

    public UploadNotasCanceladasResponse() {
    }

    public UploadNotasCanceladasResponse(
           org.tempuri.UploadNotasCanceladasResponseUploadNotasCanceladasResult uploadNotasCanceladasResult) {
           this.uploadNotasCanceladasResult = uploadNotasCanceladasResult;
    }


    /**
     * Gets the uploadNotasCanceladasResult value for this UploadNotasCanceladasResponse.
     * 
     * @return uploadNotasCanceladasResult
     */
    public org.tempuri.UploadNotasCanceladasResponseUploadNotasCanceladasResult getUploadNotasCanceladasResult() {
        return uploadNotasCanceladasResult;
    }


    /**
     * Sets the uploadNotasCanceladasResult value for this UploadNotasCanceladasResponse.
     * 
     * @param uploadNotasCanceladasResult
     */
    public void setUploadNotasCanceladasResult(org.tempuri.UploadNotasCanceladasResponseUploadNotasCanceladasResult uploadNotasCanceladasResult) {
        this.uploadNotasCanceladasResult = uploadNotasCanceladasResult;
    }

    private java.lang.Object __equalsCalc = null;
    public synchronized boolean equals(java.lang.Object obj) {
        if (!(obj instanceof UploadNotasCanceladasResponse)) return false;
        UploadNotasCanceladasResponse other = (UploadNotasCanceladasResponse) obj;
        if (obj == null) return false;
        if (this == obj) return true;
        if (__equalsCalc != null) {
            return (__equalsCalc == obj);
        }
        __equalsCalc = obj;
        boolean _equals;
        _equals = true && 
            ((this.uploadNotasCanceladasResult==null && other.getUploadNotasCanceladasResult()==null) || 
             (this.uploadNotasCanceladasResult!=null &&
              this.uploadNotasCanceladasResult.equals(other.getUploadNotasCanceladasResult())));
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
        if (getUploadNotasCanceladasResult() != null) {
            _hashCode += getUploadNotasCanceladasResult().hashCode();
        }
        __hashCodeCalc = false;
        return _hashCode;
    }

    // Type metadata
    private static org.apache.axis.description.TypeDesc typeDesc =
        new org.apache.axis.description.TypeDesc(UploadNotasCanceladasResponse.class, true);

    static {
        typeDesc.setXmlType(new javax.xml.namespace.QName("http://tempuri.org/", ">UploadNotasCanceladasResponse"));
        org.apache.axis.description.ElementDesc elemField = new org.apache.axis.description.ElementDesc();
        elemField.setFieldName("uploadNotasCanceladasResult");
        elemField.setXmlName(new javax.xml.namespace.QName("http://tempuri.org/", "UploadNotasCanceladasResult"));
        elemField.setXmlType(new javax.xml.namespace.QName("http://tempuri.org/", ">>UploadNotasCanceladasResponse>UploadNotasCanceladasResult"));
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
