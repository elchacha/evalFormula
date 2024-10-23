global interface IntFormulaWrapper {
  
    void setRecord(SObject record);

    // must return all declared variables with getter other than the Sobject if any 
    List<String> getDeclaredVariables();

    // must return the name of the variable containing the Sobject
    String getVarRecordName();

    // Should return all declaredVariables including varRecordName and the usage/description for each fields
    Map<String,String> getFieldsUsage();

} 