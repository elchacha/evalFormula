public with sharing class EvalApexDemo {

    /*
    simple formula example :
    contact id : 001d2000008CmCMAA0 / 001d2000008CmCOAA0

     Name & ' and owner account is '  & Owner.FirstName & '  ' & Owner.LastName

    wrapped Example :

    Account : 

    001d2000008CmCMAA0 / 001d2000008CmCOAA0

    nbContacts + ' contacts records for recordName : '+ acct.Name +' and owner account is '  + acct.Owner.FirstName +' ' + acct.Owner.LastName

    EvalFormulaExample__c
    a04d2000000DxtVAAS

    hardCodedString2 & ' ' & record.Id

    */

    public static Map<String,FormulaEval.FormulaReturnType> types = new Map<String,FormulaEval.FormulaReturnType>();

    static {
        types.put('Checkbox',FormulaEval.FormulaReturnType.BOOLEAN);   
        types.put('Date',FormulaEval.FormulaReturnType.Date);   
        types.put('DateTime',FormulaEval.FormulaReturnType.DATETIME);   
        types.put('Number',FormulaEval.FormulaReturnType.LONG);   
        types.put('Percent',FormulaEval.FormulaReturnType.DECIMAL);   
        types.put('Text',FormulaEval.FormulaReturnType.STRING);   
        types.put('Time',FormulaEval.FormulaReturnType.TIME);   
    }

    static String formulaToRun;
    static System.type wrapperClass; 
    static IntFormulaWrapper wrappedRecord;


    @AuraEnabled
    public static ObjectInfo getObjectInfo(Id recordId){
        return new ObjectInfo(recordId);
    }


    @AuraEnabled
    public static Map<String,String> getWrapperFields(String wrapperName){
        IntFormulaWrapper wrappedRecord = (IntFormulaWrapper)Type.forName(wrapperName).newInstance();
        return wrappedRecord.getFieldsUsage();
    }


    @AuraEnabled
    public static Object testFormula(Id recordId,String formulaType,String formulaValue,boolean userMode){

        FormulaEval.FormulaInstance formulaInstance = null;
        Schema.SObjectType recordType = (Schema.SObjectType)recordId.getSobjectType();
        formulaToRun=formulaValue;

        try {
            try {
                wrapperClass=getWrapperClass(recordType);
                System.debug('could  find a wrapper for :'+recordType +'with name : '+wrapperClass);
                wrappedRecord = (IntFormulaWrapper)wrapperClass.newInstance();
                if(isWrapperNeeded()){
                    formulaInstance=Formula.builder()
                    .withReturnType (types.get(formulaType))
                    .withType (wrapperClass)
                    .withFormula (formulaValue)
                    .build();
                }else{
                    System.debug('not using wrapper finally');
                    formulaInstance=Formula.builder()
                    .withReturnType (types.get(formulaType))
                    .withType (recordType)
                    .withFormula (formulaValue)
                    .build();
                    wrapperClass=null;
                }

    
                
    
            } catch (Exception e) {
                System.debug('could not find a wrapper for :'+recordType);
                System.debug(e);
    
                formulaInstance=Formula.builder()
                .withReturnType (types.get(formulaType))
                .withType (recordType)
                .withFormula (formulaValue)
                .build();
            }
        } catch (FormulaValidationException fve) {
            return ' error in formula or type : '+  fve.getMessage();
        } catch (Exception e){
            return ' untype error : '+  e.getMessage();
        }
        
        List<String> neededFields = new List<String>(formulaInstance.getReferencedFields());
        if(wrapperClass!=null){
            neededFields=filterNeededFields();
        }
        SObject obj=null;
        if(neededFields.size()>0){
            String queryStr = 'SELECT ' + String.join(neededFields,',') + ' FROM '+recordId.getSobjectType()+' WHERE Id=:recordId';
            if(userMode){
                obj = Database.query(queryStr,AccessLevel.USER_MODE);
            }else{
                obj = Database.query(queryStr);            
            }
        }else{
            obj=recordType.newSObject();
            obj.Id=recordId;
        }


        Object result=null;

        try {
            if(wrapperClass==null){
                result = formulaInstance.evaluate(obj);
            }else{
                wrappedRecord.setRecord(obj);
                result= formulaInstance.evaluate(wrappedRecord);
            }
        } catch (Exception e) {
            return ' unexpected error during eval : '+  e.getMessage();
        }
        return result;

    }


    // remove all "field" that are in fact wrapper property
    private static List<String> filterNeededFields(){
        Map<String, Schema.SObjectField> schemaFieldMap = Schema.SObjectType.Account.fields.getMap();
        FormulaEval.FormulaInstance formulaInstance=Formula.builder()
        .withReturnType (FormulaEval.FormulaReturnType.STRING)
        .withType (Account.getSObjectType())
        .withFormula (cleanFormula())
        .build();
        List<String> neededFields = new List<String>(formulaInstance.getReferencedFields());
        System.debug('Fields to retrieve : '+ neededFields);

        return neededFields;
    }


    private static String cleanFormula(){
        IntFormulaWrapper wrappedRecord = (IntFormulaWrapper)wrapperClass.newInstance();

        // remove all reference to var Sobject so that we can list the needed fields
        String cleanFormulaResult = formulaToRun.replaceAll(wrappedRecord.getVarRecordName()+'.', '');

        for(String varDeclared : wrappedRecord.getDeclaredVariables()){
            cleanFormulaResult=cleanFormulaResult.replaceAll(varDeclared, '\'N/A\'');
        }

        System.debug('Clean formula without variable from the wrapper : '+ cleanFormulaResult);

        return cleanFormulaResult;
    }

    // looking if we really need to use the wrapper
    private static boolean isWrapperNeeded(){
        if(formulaToRun.contains(wrappedRecord.getVarRecordName()+'.')) return true;
        for(String varWrapper : wrappedRecord.getDeclaredVariables()){
            if(formulaToRun.contains(varWrapper)) return true;
        }
        return false;
    }

    private static System.Type getWrapperClass(Schema.SObjectType recordType ){
        String sRecordType = String.valueOf(recordType).replaceAll('__c','');
        try {
            return Type.forName('Formula'+sRecordType+'Wrapper');
        } catch (Exception e) {
            return null;
        }
    }


    public class ObjectInfo{
        @AuraEnabled
        public String objectName;
        @AuraEnabled
        public String wrapperClass;

        public ObjectInfo(Id recordId){
            Schema.SObjectType recordType = (Schema.SObjectType)recordId.getSobjectType();
            objectName = String.valueOf(recordType);
            wrapperClass=String.valueOf(getWrapperClass(recordType));
        }
    }
}