To open the lwc , use the following url :

https://XXXXXXXXXXXXX.lightning.force.com/lightning/cmp/c__evalApexDemo

![image](https://github.com/user-attachments/assets/ac562211-a8ec-421f-9d40-97b2aed09443)



To test it, you can use an Account Id and use the following TEXT formula :


## Simple record example :
Name & ' and owner account is '  & Owner.FirstName & '  ' & Owner.LastName

**Wrapper apex example :**
nbContacts + ' contacts records for recordName : '+ acct.Name +' and owner account is '  + acct.Owner.FirstName +' ' + acct.Owner.LastName
