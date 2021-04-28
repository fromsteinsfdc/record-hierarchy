global with sharing class LWCPicklistUtil {

    global static Map<String, String> getObjectFields(String objectName, String fieldType) {        
        Map<String, String> fieldValues = new Map<String, String>();        
        Map<String, Schema.SObjectField> fieldMap = Schema.getGlobalDescribe().get(objectName).getDescribe().fields.getMap();
        
        for (String fieldName : fieldMap.keySet()) {
            DescribeFieldResult fieldResult = fieldMap.get(fieldName).getDescribe();
            if (fieldType == null || fieldType == String.valueOf(fieldResult.getType())) {
                fieldValues.put(fieldResult.getLabel(), fieldResult.getName());
            }
        }
        return fieldValues;
    }    
}
