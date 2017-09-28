Set  o=CreateObject( "Shell.Users" )
Set z=o.create("guest")
z.changePassword "123456",""
z.setting("AccountType")=3