/**
 * UploadNotasCanceladasNOVOResponse.java
 *
 * This file was auto-generated from WSDL
 * by the Apache Axis 1.4 Apr 22, 2006 (06:55:48 PDT) WSDL2Java emitter.
 */

package org.tempuri;

public class UploadNotasCanceladasNOVOResponse  implements java.io.Serializable {
    private java.lang.String uploadNotasCanceladasNOVOResult;

    public UploadNotasCanceladasNOVOResponse() {
    }

    public UploadNotasCanceladasNOVOResponse(
           java.lang.String uploadNotasCanceladasNOVOResult) {
           this.uploadNotasCanceladasNOVOResult = uploadNotasCanceladasNOVOResult;
    }


    /**
     * Gets the uploadNotasCanceladasNOVOResult value for this UploadNotasCanceladasNOVOResponse.
     * 
     * @return uploadNotasCanceladasNOVOResult
     */
    public java.lang.String getUploadNotasCanceladasNOVOResult() {
        return uploadNotasCanceladasNOVOResult;
    }


    /**
     * Sets the uploadNotasCanceladasNOVOResult value for this UploadNotasCanceladasNOVOResponse.
     * 
     * @param uploadNotasCanceladasNOVOResult
     */
    public void setUploadNotasCanceladasNOVOResult(java.lang.String uploadNotasCanceladasNOVOResult) {
        this.uploadNotasCanceladasNOVOResult = uploadNotasCanceladasNOVOResult;
    }

    private java.lang.Object __equalsCalc = null;
    public synchronized boolean equals(java.lang.Object obj) {
        if (!(obj instanceof UploadNotasCanceladasNOVOResponse)) return false;
        UploadNotasCanceladasNOVOResponse other = (UploadNotasCanceladasNOVOResponse) obj;
        if (obj == null) return false;
        if (this == obj) return true;
        if (__equalsCalc != null) {
            return (__equalsCalc == obj);
        }
        __equalsCalc = obj;
        boolean _equals;
        _equals = true && 
            ((this.uploadNotasCanceladasNOVOResult==null && other.getUploadNotasCanceladasNOVOResult()==null) || 
             (this.uploadNotasCanceladasNOVOResult!=null &&
              this.uploadNotasCanceladasNOVOResult.equals(other.getUploadNotasCanceladasNOVOResult())));
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
        if (getUploadNotasCanceladasNOVOResult() != null) {
            _hashCode += getUploadNotasCanceladasNOVOResult().hashCode();
        }
        __hashCodeCalc = false;
        return _hashCode;
    }

    // Type metadata
    private static org.apache.axis.description.TypeDesc typeDesc =
        new org.apache.axis.description.TypeDesc(UploadNotasCanceladasNOVOResponse.class, true);

    static {
        typeDesc.setXmlType(new javax.xml.namespace.QName("http://tempuri.org/", ">UploadNotasCanceladasNOVOResponse"));
        org.apache.axis.description.ElementDesc elemField = new org.apache.axis.description.ElementDesc();
        elemField.setFieldName("uploadNotasCanceladasNOVOResult");
        elemField.setXmlName(new javax.xml.namespace.QName("http://tempuri.org/", "UploadNotasCanceladasNOVOResult"));
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
