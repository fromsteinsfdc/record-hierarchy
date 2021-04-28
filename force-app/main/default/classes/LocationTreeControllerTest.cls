@isTest
public with sharing class LocationTreeControllerTest {
    
    @isTest
    public static void doTest() {
        Schema.Location loc = new Schema.Location(Name='Test Location', TimeZone=String.valueOf(UserInfo.getTimeZone()));
        insert loc;
        LocationTreeController.getHierarchy(loc.id);
    }
    
}
