public with sharing class LocationTreeController {
    @AuraEnabled
    public static Result getHierarchy(Id recordId) {

        // Dynamically querying the fields to account for any orgs without the wkcc__Status__c custom field
        String queryFields = 'SELECT Id, ParentLocationId, RootLocationId, Name, LocationLevel, LocationType';
        if (Schema.Location.sObjectType.getDescribe().fields.getMap().containsKey('wkcc__Status__c')) {
            queryFields +=', wkcc__Status__c';
        }
        Schema.Location originalLoc = Database.query(queryFields +' FROM Location WHERE Id =: recordId');
        List<Id> currentParentIds = new List<Id>{originalLoc.RootLocationId};
        List<Map<Id, List<Schema.Location>>> masterList = new List<Map<Id, List<Schema.Location>>>();
        while (!currentParentIds.isEmpty()) {
            List<Schema.Location> currentList = Database.query(queryFields +' FROM Location WHERE ParentLocationId IN: currentParentIds');
            currentParentIds.clear();
            Map<Id, List<Schema.Location>> locationMap = new Map<Id, List<Schema.Location>>();
            for (Schema.Location currentLoc : currentList) {
                currentParentIds.add(currentLoc.Id);
                List<Schema.Location> tempList = locationMap.containsKey(currentLoc.ParentLocationId) ? locationMap.get(currentLoc.ParentLocationId) : new List<Schema.Location>();
                tempList.add(currentLoc);
                locationMap.put(currentLoc.ParentLocationId, tempList);
            }
            if (!locationMap.isEmpty())
                masterList.add(locationMap);
        }
        Result res = new Result();
        res.originalLevel = originalLoc.LocationLevel;
        res.masterList = masterList;
        res.originalId = recordId;
        res.rootLocation = Database.query(queryFields +' FROM Location WHERE  Id = \''+ originalLoc.RootLocationId+'\'');
        return res;    
    }

    public class Result {
        @AuraEnabled public Integer originalLevel;
        @AuraEnabled public List<Map<Id, List<Schema.Location>>> masterList;
        @AuraEnabled public Schema.Location rootLocation;
        @AuraEnabled public Id originalId;
    }
}
