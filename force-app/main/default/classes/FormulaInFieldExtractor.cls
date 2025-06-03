public with sharing class FormulaInFieldExtractor {

    // Account.Parent => Account, CustomObject1__r.CustomObject2__r => CustomObject2__c
    static Map<String,String> relObjectToApiName = new Map<String,String>();
    static Map<String,Map<String, SObjectField>> mapObjectFields = new Map<String,Map<String, SObjectField>>();
    static Set<String> allFields = new Set<String>();


    public static Set<String> getAllField(String objectName,String aFormula,FormulaEval.FormulaReturnType formulAType){
        return getAllField(objectName, aFormula, formulAType, '');
    }

    private static Set<String> getAllField(String objectName,String aFormula,FormulaEval.FormulaReturnType formulAType,String initialRelation){
         Set<String> tmpFields;
            FormulaEval.FormulaInstance formulaInstance=Formula.builder()
            .withReturnType (formulAType)
            .withType(((SObject) Type.forName(objectName).newInstance()).getSObjectType())
            .withFormula (aFormula)
            .build();
            tmpFields=formulaInstance.getReferencedFields();

        initParentRelationShip(objectName);
        for(String field : tmpFields){
            if(!allFields.contains(field)){
                treatFieldFormula(objectName,field);
                allFields.add(initialRelation+field);
            }
        }
        System.debug(JSON.serialize(allFields));
        return allFields;
    }


    private static void treatFieldFormula(String objectName,String fieldName){
        String initialRelation='';
        if(fieldName.contains('.')){
            initialRelation=fieldName.substring(0,fieldName.lastIndexOf('.')+1);
            objectName = getObjectName(fieldName);
            fieldName = fieldName.substring(fieldName.lastIndexOf('.')+1);

        }
        if(mapObjectFields.get(objectName).get(fieldName).getDescribe().getCalculatedFormula()!=null){
            system.debug(objectName);
            system.debug(fieldName);
            getAllField(objectName,mapObjectFields.get(objectName).get(fieldName).getDescribe().getCalculatedFormula(),FormulaEval.FormulaReturnType.DOUBLE,initialRelation);
        }
    }


    // load object/fields needed in cache
    private static String getObjectName(String fieldName){
        String objectRelationName= fieldName.substring(0,fieldName.indexOf('.'));
        Schema.DescribeSObjectResult objDescribe = Schema.describeSObjects(new String[] { relObjectToApiName.get(objectRelationName)}, SObjectDescribeOptions.DEFERRED)[0];
        String objectName = objDescribe.getName();
        initParentRelationShip(objectName);
        relObjectToApiName.put(objectRelationName, objectName);
        mapObjectFields.put(objectName,objDescribe.fields.getMap());
        fieldName=fieldName.substring(objectName.length()+1);
        if(fieldName.contains('.')){
            objectName=getObjectName(fieldName);
        }

        return objectName;
    }


    public static void initParentRelationShip(String sObjectName){
        if(!mapObjectFields.containsKey(sObjectName)){
            Schema.DescribeSObjectResult objDescribe = Schema.describeSObjects(new String[] { sObjectName}, SObjectDescribeOptions.DEFERRED)[0];
            mapObjectFields.put(sObjectName,objDescribe.fields.getMap());
            for(SObjectField field : objDescribe.fields.getMap().values()){
                DescribeFieldResult dfr = field.getDescribe();
                if (dfr.getRelationshipName()!=null&&!dfr.getReferenceTo().isEmpty()){
                    relObjectToApiName.put(dfr.getRelationshipName(),dfr.getReferenceTo()[0].getDescribe().getName());
                }
            }
        }
    }


}