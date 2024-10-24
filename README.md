To open the lwc , use the following url :

https://XXXXXXXXXXXXX.lightning.force.com/lightning/cmp/c__evalApexDemo

![image](https://github.com/user-attachments/assets/ac562211-a8ec-421f-9d40-97b2aed09443)

<img width="484" alt="{65FE2FBA-EA23-4836-AFF4-253CF24DCE27}" src="https://github.com/user-attachments/assets/a3f6e1c6-88c1-44f9-ae9b-f8a81450239d">




To test it, you can use an Account Id and use the following TEXT formula :


### Simple record example :
Name & ' and owner account is '  & Owner.FirstName & '  ' & Owner.LastName

### Wrapper apex example :
nbContacts + ' contacts records for recordName : '+ acct.Name +' and owner account is '  + acct.Owner.FirstName +' ' + acct.Owner.LastName
