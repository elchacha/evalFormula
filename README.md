To open the lwc , use the following url :

https://XXXXXXXXXXXXX.lightning.force.com/lightning/cmp/c__evalApexDemo

<img width="721" alt="{F32BE9B0-0031-41FF-A88E-4B353743CB95}" src="https://github.com/user-attachments/assets/cbf15cce-135d-4ebb-a295-23afefd5808d">





To test it, you can use an Account Id and use the following TEXT formula :


### Simple record example :
Name & ' and owner account is '  & Owner.FirstName & '  ' & Owner.LastName

### Wrapper apex example :
nbContacts + ' contacts records for recordName : '+ acct.Name +' and owner account is '  + acct.Owner.FirstName +' ' + acct.Owner.LastName
