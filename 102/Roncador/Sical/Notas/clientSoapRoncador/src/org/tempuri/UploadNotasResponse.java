/**
 * UploadNotasResponse.java
 *
 * This file was auto-generated from WSDL
 * by the Apache Axis 1.4 Apr 22, 2006 (06:55:48 PDT) WSDL2Java emitter.
 */

package org.tempuri;

public class UploadNotasResponse  implements java.io.Serializable {
    private org.tempuri.UploadNotasResponseUploadNotasResult uploadNotasResult;

    public UploadNotasResponse() {
    }

    public UploadNotasResponse(
           org.tempuri.UploadNotasResponseUploadNotasResult uploadNotasResult) {
           this.uploadNotasResult = uploadNotasResult;
    }


    /**
     * Gets the uploadNotasResult value for this UploadNotasResponse.
     * 
     * @return uploadNotasResult
     */
    public org.tempuri.UploadNotasResponseUploadNotasResult getUploadNotasResult() {
        return uploadNotasResult;
    }


    /**
     * Sets the uploadNotasResult value for this UploadNotasResponse.
     * 
     * @param uploadNotasResult
     */
    public void setUploadNotasResult(org.tempuri.UploadNotasResponseUploadNotasResult uploadNotasResult) {
        this.uploadNotasResult = uploadNotasResult;
    }

    private java.lang.Object __equalsCalc = null;
    public synchronized boolean equals(java.lang.Object obj) {
        if (!(obj instanceof UploadNotasResponse)) return false;
        UploadNotasResponse other = (UploadNotasResponse) obj;
        if (obj == null) return false;
        if (this == obj) return true;
        if (__equalsCalc != null) {
            return (__equalsCalc == obj);
        }
        __equalsCalc = obj;
        boolean _equals;
        _equals = true && 
            ((this.uploadNotasResult==null && other.getUploadNotasResult()==null) || 
             (this.uploadNotasResult!=null &&
              this.uploadNotasResult.equals(other.getUploadNotasResult())));
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
        if (getUploadNotasResult() != null) {
            _hashCode += getUploadNotasResult().hashCode();
        }
        __hashCodeCalc = false;
        return _hashCode;
    }

    // Type metadata
    private static org.apache.axis.description.TypeDesc typeDesc =
        new org.apache.axis.description.TypeDesc(UploadNotasResponse.class, true);

    static {
        typeDesc.setXmlType(new javax.xml.namespace.QName("http://tempuri.org/", ">UploadNotasResponse"));
        org.apache.axis.description.ElementDesc elemField = new org.apache.axis.description.ElementDesc();
        elemField.setFieldName("uploadNotasResult");
        elemField.setXmlName(new javax.xml.namespace.QName("http://tempuri.org/", "UploadNotasResult"));
        elemField.setXmlType(new javax.xml.namespace.QName("http://tempuri.org/", ">>UploadNotasResponse>UploadNotasResult"));
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
