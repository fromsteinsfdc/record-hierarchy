public with sharing class HierarchyController {

    @AuraEnabled
    public static Result getHierarchy(Id recordId, String parentField, String fieldString) {
        String objectName = Id.valueOf(recordId).getSObjectType().getDescribe().getName();
        String queryString = '';

        // Use a set to eliminate any duplicate values in the field names, and only add valid field names
        Set<String> fields = new Set<String>{parentField};
        fields.addAll(fieldString.split(','));
        for (String field : fields) {
            if (Schema.getGlobalDescribe().get(objectName).getDescribe().fields.getMap().containsKey(field)) {
                queryString += field+',';
            } else {
                if (field == parentField) {
                    System.debug('Error: invalid Parent Record field');
                    return null;        
                }
            }
        }
        if (queryString.length() == 0) {
            System.debug('Error: no valid fields');
            return null;
        }
        queryString = 'SELECT '+ queryString.substring(0, queryString.length()-1);
        
        // Find root record by going up the hierarchy until there's no more parent records
        String filterId = recordId;
        SObject rootRecord;
        while (rootRecord == null) {
            SObject record = Database.query(queryString +' FROM '+ ObjectName+' WHERE Id =: filterId');
            if (record.get(parentField) == null) {
                rootRecord = record;                
            } else {
                filterId = String.valueOf(record.get(parentField));
            }
        }

        List<Id> currentParentIds = new List<Id>{rootRecord.Id};
        List<Map<Id, List<SObject>>> masterList = new List<Map<Id, List<SObject>>>();
        while (!currentParentIds.isEmpty()) {
            List<SObject> currentList = Database.query(queryString +' FROM '+ ObjectName+' WHERE '+ parentField +' IN: currentParentIds');
            currentParentIds.clear();
            Map<Id, List<SObject>> recordMap = new Map<Id, List<SObject>>();
            for (SObject currentRecord : currentList) {
                currentParentIds.add(currentRecord.Id);
                List<SObject> tempList = recordMap.containsKey(getId(currentRecord.get(parentField))) ? recordMap.get(getId(currentRecord.get(parentField))) : new List<SObject>();
                tempList.add(currentRecord);
                recordMap.put(Id.valueOf(getId(currentRecord.get(parentField))), tempList);
            }
            if (!recordMap.isEmpty())
                masterList.add(recordMap);
        }
        Result res = new Result();
        res.masterList = masterList;
        res.rootRecord = rootRecord;
        return res;    
    }

    public static Id getId(Object obj) {
        return Id.valueOf(String.valueOf(obj));
    }

    public class Result {
        @AuraEnabled public List<Map<Id, List<SObject>>> masterList;
        @AuraEnabled public SObject rootRecord;
    }
}
