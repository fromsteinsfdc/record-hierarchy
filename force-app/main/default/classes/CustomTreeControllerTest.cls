@isTest
public with sharing class CustomTreeControllerTest {
    @isTest
    public static void doTest() {
        Account parent = new Account(Name = 'Parent Account');
        insert parent;
        Account child = new Account(Name = 'Child Account', ParentId = parent.Id);
        insert child;
        CustomTreeController.getHierarchy(child.id, 'ParentId', 'Name', null);
    }
}
