import { LightningElement } from 'lwc';
import testFormula from '@salesforce/apex/EvalApexDemo.testFormula';

export default class EvalApexDemo extends LightningElement {

    formulaType;
    recordId;
    formula1;
    formula2;
    result1;
    result2;
    optionalFields;

    get options() {
        return [
            { label: 'Checkbox', value: 'Checkbox' },
            { label: 'Date', value: 'Date' },
            { label: 'DateTime', value: 'DateTime' },
            { label: 'Number', value: 'Numnber' },
            { label: 'Percent', value: 'Percent' },
            { label: 'Text', value: 'Text' },
            { label: 'Time', value: 'Time' },
        ];
    }

    handleChange(event) {
        this.formulaType = event.detail.value;
    }

    setValue1(event){
        this.formula1 = event.detail.value;
    }

    setValue2(event){
        this.formula2 = event.detail.value;
    }

    setRecordId(){
        this.recordId = event.detail.value;
    }

    setOptionalFields(){
        this.optionalFields=event.detail.value;
    }

    calculate(){
        console.log(this.recordId);
        console.log(this.formula1);
        console.log(this.formula2);
        console.log(this.formulaType);
        if(!this.optionalFields)this.optionalFields=null;
        if(this.formula1){
            testFormula({recordId: this.recordId , formulaType : this.formulaType,formulaValue : this.formula1,optionalFields : this.optionalFields}).then(data => {
                this.result1=data;
            });
        }
        if(this.formula2){
            testFormula({recordId: this.recordId , formulaType : this.formulaType,formulaValue : this.formula2,optionalFields : this.optionalFields}).then(data => {
                this.result2=data;
            });
        }

    }

}