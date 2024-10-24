To open the lwc , use the following url :

https://XXXXXXXXXXXXX.lightning.force.com/lightning/cmp/c__evalApexDemo

<img width="718" alt="{68971B5C-BBE8-4EBD-A9F2-D8B791A75F7F}" src="https://github.com/user-attachments/assets/9bb12b91-7208-451b-bdac-86f7fc3b2dc8">





To test it, you can use an Account Id and use the following TEXT formula :


### Simple record example :
Name & ' and owner account is '  & Owner.FirstName & '  ' & Owner.LastName

### Wrapper apex example :
nbContacts + ' contacts records for recordName : '+ acct.Name +' and owner account is '  + acct.Owner.FirstName +' ' + acct.Owner.LastName
