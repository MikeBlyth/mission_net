module IncomingMailsHelper
  
  def help_content
s = <<"HELPTEXT"
Accessing the SIM Nigeria Database by Email

The SIM Nigeria member database can be accessed online (from your web browser) but
only if you have obtained a user name and password from the SIM office.
However, you can request information by email, as long as your email address
matches one of your addresses registered in the database.

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
   
travel   
   Get current travel schedule
   
directory
   Get current SIM Nigeria phone number & email list
   
birthdays
   Get current SIM Nigeria birthdays list
HELPTEXT
    return s
  end
  
end # module


