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

}