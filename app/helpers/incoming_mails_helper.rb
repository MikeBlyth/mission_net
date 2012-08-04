module IncomingMailsHelper
  
  def help_content
s = <<"HELPTEXT"
Accessing the Joslink/Josalerts Database by Email

The database can be accessed online from your web browser at https://joslink.herokuapp.com.
However, you can also request information and perform actions via email.

Database requests should go in the body of the email, one command per line.
Commands include:

info <Name> 
   Get contact information on people matching <Name>. 
   You can use just about any format for the name, examples:
   
   info Donald Duck
   info Don
   info Duck
   info Duck, Don
   info Duc
   
   Only one <Name> can be requested per line, but you can use multiple
   lines and will receive one email for each request.
   
BROADCASTING MESSAGE TO GROUPS 

d group another_group: This is the message to be sent out to people...
  
  The 'd' command sends messages *by SMS* to the specified groups. 
  Remember that an SMS message sent by this system is limited to roughly
  145 characters.
  
email group another_group: This is the message to be sent out to people...

  The 'email' command sends messages by EMAIL to the specified groups.
  Email messages are not limited in length, but they are not formatted at 
  all so are best suited for fairly short communications.

d+email group another_group: This is the message to be sent out to people...
  
  The 'd+email' command, naturally, sends both SMS and email. The SMS message is
  still cut off after at most 150 characters. 'email+d' works the same as 'd+email'.

If you have any questions or this information appears to be out-of-date, please
contact a system administrator.
HELPTEXT
    return s
  end
  
end # module


