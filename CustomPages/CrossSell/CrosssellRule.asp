<!-- #include file ="..\sagecrm.js" -->

<%


  if (CRM.Mode<Edit) CRM.Mode=Edit;

  record=CRM.CreateRecord("Opportunity");

  record.SetWorkFlowInfo("Opportunity Workflow", "Lead");


  WebPicker=CRM.GetBlock("OpportunityWebPicker");

  EntryGroup=CRM.GetBlock("OpportunityDetailBox");

  StatusBox = CRM.GetBlock("CrosssellStatusBox");

  WebPicker.ShowValidationErrors = false;
  EntryGroup.ShowValidationErrors = false;
  StatusBox.ShowValidationErrors = false;

  EntryGroup.CopyErrorsToPageErrorContent = true;
  StatusBox.CopyErrorsToPageErrorContent = true;


  CRM.SetContext("New");

  //set some default values from context - company/person/user/channel

  CompId = CRM.GetContextInfo('Opportunity','Oppo_PrimaryCompanyId');
  if ((Defined(CompId)) && (CompId > 0))
  {
    Entry = WebPicker.GetEntry("Oppo_PrimaryCompanyId");
    if (Entry != null) {
      Entry.DefaultValue = CompId;
    }
  }

  PersId = CRM.GetContextInfo('Opportunity','Oppo_PrimaryPersonId');
  if ((Defined(PersId)) && (PersId > 0))
  {
    Entry = EntryGroup.GetEntry("Oppo_PrimaryPersonId");
    if (Entry != null) {
      Entry.DefaultValue = PersId;
    }
  }

  UserId = CRM.GetContextInfo('Opportunity', 'Oppo_AssignedUserId');
  if ((Defined(UserId)) && (UserId > 0))
  {
    Entry = StatusBox.GetEntry("Oppo_AssignedUserId");
    if (Entry != null) {
      Entry.DefaultValue = UserId;
    }
  }

  ChanId = CRM.GetContextInfo('Opportunity', 'Oppo_ChannelId');
  if ((Defined(ChanId)) && (ChanId > 0))
  {
    Entry = StatusBox.GetEntry("Oppo_ChannelId");
    if (Entry != null) {
      Entry.DefaultValue = ChanId;
    }
  }

  //turn on cross sell checkbox  - see OpportunityDetailBox create scripts for other logic 
  Entry = EntryGroup.GetEntry("Oppo_SCRMIsCrossSell");
  if (Entry != null) {
    Entry.DefaultValue = "on";
    Entry.Hidden = false;
    Entry.ReadOnly = true;
  }



  container=CRM.GetBlock("container");
  container.AddBlock(WebPicker);
  container.AddBlock(EntryGroup);
  container.AddBlock(StatusBox);

  container.Title = CRM.GetTrans('GenCaptions','CrossSellOpportunityTitle');

  container.AddButton(
   CRM.Button("Cancel", "cancel.gif", 
      CRM.Url("521")));


  try
  {
    CRM.AddContent(container.Execute(record));
  }
  catch(err)
  {
    //Validation errors fall in here - redraw in edit mode
    if(CRM.Mode==Save) {
      CRM.Mode = Edit;
      CRM.AddContent(container.Execute(record));
    }
  }


  if(CRM.Mode==Save) {    
    CRM.SetContext("Opportunity", record.RecordId);  //add to recent list
    var sOppoURL = CRM.URL(260)+'&InfoBannerCode=NewCrossSell';
    // Redirect back to original opportunity
    Response.Redirect(sOppoURL);
  }
  else { 
    Response.Write(CRM.GetPage());
  }


%>