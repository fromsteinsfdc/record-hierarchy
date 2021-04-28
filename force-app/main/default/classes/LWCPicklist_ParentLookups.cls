global class LWCPicklist_ParentLookups extends VisualEditor.DynamicPickList{
    
    VisualEditor.DynamicPickListRows rowValues;

    global LWCPicklist_ParentLookups(VisualEditor.DesignTimePageContext context) {
        rowValues = getParentLookups(context.entityName);
    }

    public static VisualEditor.DynamicPickListRows getParentLookups(String objectName) {
        VisualEditor.DynamicPickListRows  picklistVals = new VisualEditor.DynamicPickListRows();
        Map<String, Schema.SObjectField> fieldMap = Schema.getGlobalDescribe().get(objectName).getDescribe().fields.getMap();
        
        for (String fieldName : fieldMap.keySet()) {
            DescribeFieldResult fieldResult = fieldMap.get(fieldName).getDescribe();
            if (String.valueOf(fieldResult.getType()) == 'reference' && fieldResult.getReferenceTo().contains(Schema.getGlobalDescribe().get(objectName))) {
                picklistVals.addRow(new VisualEditor.DataRow(fieldResult.getName(), fieldResult.getName()));
            }
        }
        return picklistVals;
    }

    global override VisualEditor.DataRow getDefaultValue(){
        if (rowValues.size() > 0 )
            return null;
        return rowValues.get(0);
    }

    global override VisualEditor.DynamicPickListRows getValues() {
        return rowValues;
    }

}