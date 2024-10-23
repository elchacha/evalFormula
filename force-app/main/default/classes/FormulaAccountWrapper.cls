global with sharing class FormulaAccountWrapper implements IntFormulaWrapper{

    global Account acct { get; set; }

    public void  setRecord(Sobject record){
        acct=(Account)record;
    }

    global String nbContacts
    {
        get { return ''+Database.countQuery('SELECT COUNT() FROM Contact WHERE AccountId =\''+acct.Id+'\'');}
    }

    public String getVarRecordName(){
        return 'acct';
    }

    public List<String> getDeclaredVariables(){
        return new List<String>{'nbContacts'};
    }

    public Map<String,String> getFieldsUsage(){
        Map<String,String> result = new Map<String,String>();
        result.put('acct','Contains the account fields for the record. Must be used with acct.FIELDNAME ...');
        result.put('nbContacts','contains the number of Contacts linked to the account');
        return result;
    }

}