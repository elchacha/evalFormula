public with sharing class FormulaInFieldExtractor {

    // Account.Parent => Account, CustomObject1__r.CustomObject2__r => CustomObject2__c
    static Map<String,String> relObjectToApiName = new Map<String,String>();
    static Map<String,Map<String, SObjectField>> mapObjectFields = new Map<String,Map<String, SObjectField>>();
    static Set<String> allFields = new Set<String>();
    static Set<String> nestedFields = new Set<String>();


    static Map<schema.DisplayType,FormulaEval.FormulaReturnType> mapTypes= new Map<schema.DisplayType,FormulaEval.FormulaReturnType>();
    static{
        mapTypes.put(schema.DisplayType.PERCENT,FormulaEval.FormulaReturnType.DECIMAL);
        mapTypes.put(schema.DisplayType.DOUBLE,FormulaEval.FormulaReturnType.DOUBLE);
        mapTypes.put(schema.DisplayType.DATE,FormulaEval.FormulaReturnType.DATE);
        mapTypes.put(schema.DisplayType.DATETIME,FormulaEval.FormulaReturnType.DATETIME);
        mapTypes.put(schema.DisplayType.STRING,FormulaEval.FormulaReturnType.STRING);
        mapTypes.put(schema.DisplayType.BOOLEAN,FormulaEval.FormulaReturnType.BOOLEAN);
        mapTypes.put(schema.DisplayType.TIME,FormulaEval.FormulaReturnType.TIME);
        mapTypes.put(schema.DisplayType.INTEGER,FormulaEval.FormulaReturnType.INTEGER);
    }


    public static Set<String> getAllField(String objectName,String aFormula,FormulaEval.FormulaReturnType formulAType){
        return getAllField(objectName, aFormula, formulAType, '',false);
    }


    public static Set<String> getNestedFields(String objectName,String aFormula,FormulaEval.FormulaReturnType formulAType){
        getAllField(objectName, aFormula, formulAType, '',false);
        return nestedFields;
    }

    private static Set<String> getNestedField(String objectName,String aFormula,FormulaEval.FormulaReturnType formulAType,String initialRelation){
        return getAllField(objectName, aFormula, formulAType, initialRelation,true);
    }

    private static Set<String> getAllField(String objectName,String aFormula,FormulaEval.FormulaReturnType formulAType,String initialRelation,boolean processingNestedFields){
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
                if(processingNestedFields){
                    nestedFields.add(initialRelation+field);
                }
            }
        }
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

            Schema.DescribeFieldResult dfr = mapObjectFields.get(objectName).get(fieldName).getDescribe();

            getNestedField(objectName,dfr.getCalculatedFormula(),mapTypes.get(dfr.getType()),initialRelation);
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