global with sharing class FormulaEvalFormulaExampleWrapper implements IntFormulaWrapper{

    global EvalFormulaExample__c record { get; set; }

    public void  setRecord(Sobject record){
        this.record=(EvalFormulaExample__c)record;
    }

    global String hardCodedString1
    {
        get { return 'a value hardCoded';}
    }

    global String hardCodedString2
    {
        get { return 'another value hardCoded';}
    }


    public String getVarRecordName(){
        return 'record';
    }

    public List<String> getDeclaredVariables(){
        return new List<String>{'hardCodedString1','hardCodedString2'};
    }

    public Map<String,String> getFieldsUsage(){
        Map<String,String> result = new Map<String,String>();
        result.put('record','Contains the EvalFormulaExample__c fields for the record. Must be used with record.FIELDNAME ...');
        result.put('hardCodedString1','contains a String value ...');
        result.put('hardCodedString2','contains another String value ...');
        return result;
    }
}