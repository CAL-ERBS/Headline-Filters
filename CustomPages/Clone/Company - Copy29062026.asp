<!-- #include file ="..\accpaccrm.js" -->
<%

var Id=CRM.GetContextInfo("Quotes","Quot_OrderquoteId")
var UserID=CRM.GetContextInfo("User","user_userid")

if( CRM.Mode != Save ){
 // F=Request.QueryString("F");
// if( F == "authorisediscount.asp" ) 
 CRM.Mode=Edit;
}



Container=CRM.GetBlock("container");
Entry=CRM.GetBlock("Clone Company");
Entry.Title="Quote Company and  Contact";
Entry.CopyErrorsToPageErrorContent = true;
Entry.ShowValidationErrors = false;
Container.DisplayButton(1)=true;


Container.AddBlock(Entry);


  if (Id.toString() == 'undefined') {
     Id = new String(Request.Querystring("Key71"));
  }


  

var UseId = 0;

if (Id.indexOf(',') > 0) {
   var Idarr = Id.split(",");
   UseId = Idarr[0];
}
else if (Id != '') 
  UseId = Id;


if (UseId != 0) {

   var Idarr = Id.split(",");
CRM.SetContext("Quotes", UseId);
  

 
			record = CRM.FindRecord("Quotes", "Quot_OrderquoteId="+UseId);
     

     if(CRM.Mode == Edit)
     {
       Container.DisplayButton(Button_Continue) = false;
	   
      //Container.AddButton(CRM.Button("Save", "save.gif", "javascript:x=location.href;if (x.charAt(x.length-1)!='&')if (x.indexOf('?')>=0) x+='&'; else x+='?';x+='oppo_opportunityid="+recOrder("orde_opportunityid")+"';document.EntryForm.action=x;document.EntryForm.submit();", "Opportunity", "EDIT"));

	    
	  	   
     }
     else
     {
       Container.DisplayButton(Button_Continue) = false;
      // Container.AddButton(CRM.Button("Change","edit.gif","javascript:x=location.href;if (x.charAt(x.length-1)!='&')if (x.indexOf('?')>=0) x+='&'; else x+='?';x+='oppo_opportunityid="+recOrder("orde_opportunityid")+"&History=T';document.EntryForm.action=x;document.EntryForm.submit();", "Opportunity", "EDIT"));
	 // Container.AddButton(CRM.Button("Create Order", "Quote.gif", CRM.URL("Opportunity/CreateCreditOrder.asp")+"&E=Opportunity", 'Opportunity', 'insert'));
	  
	  	   
     }

     

      if(CRM.Mode == Save)
     {

		    CRM.AddContent(Container.Execute(record));
		
		     if ((Defined(record("quot_c_clonecompany"))) && (Defined(record("quot_c_sageaccount"))))
			 {
			 
			      if (Defined(record("quot_c_clonecontact")))
			 
			      Response.Redirect(CRM.URL("Clone/CloneQuote.asp?CompId="+record("quot_c_clonecompany")+"&PID="+record("quot_c_clonecontact")+"&SageID="+record("quot_c_sageaccount")))
				  else
                  Response.Redirect(CRM.URL("Clone/CloneQuote.asp?CompId="+record("quot_c_clonecompany")+"&SageID="+record("quot_c_sageaccount")))
				  
			 }
			


      }
	  else
	  {
        CRM.AddContent(Container.Execute(record));
		}
  
  }
  
  Response.Write(CRM.GetPage("Quote"));


%>