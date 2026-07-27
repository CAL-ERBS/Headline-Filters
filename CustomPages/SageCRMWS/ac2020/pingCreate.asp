<!-- #include file ="sagecrm.js" -->
<%    

//no longer used
so breaking with this code

    var entity = Request.Form("entity");
    var entityId = Request.Form("entityId");
    var body = Request.Form("body");
    var title = Request.Form("title");
    var recipientUserId = Request.Form("recipientUserId");

    var communication = CRM.CreateRecord("Communication");
    communication.comm_status = "Created";
    communication.comm_type="Ping";
    communication.comm_note = body;
    communication.comm_action = entity;
	communication.comm_description = "/entity/" + entity + "/" + entityId;
    communication.comm_subject = title;
	communication.comm_datetime = new Date().getVarDate();
    communication.SaveChangesNoTls();

    updateEntityByFields("communication", communication.RecordId);
    var cmli = CRM.CreateRecord("Comm_Link");
    cmli.cmli_comm_communicationid=communication.RecordId;
	cmli.cmli_comm_userid=recipientUserId;
    cmli.SaveChangesNoTls();
   

	try {
		cmli("cmli_comm_" + entity + "id") = entityId;
		cmli.SaveChangesNoTls();
	} catch(e) {
		//fish
		//Response.Write(e.message);		
	}
	 updateEntityByFields("Comm_Link", cmli.RecordId);
    //send push 
    var recipient = CRM.FindRecord("User", "user_userid=" + recipientUserId); 
    if (Defined(recipient.user_ct_fcmtoken)) {
	
        var pushData = {
            "Notification": { 
                "Title": new String(title), 
                "Body" : new String(body),
                "ImageUrl" : "" 
            },
            "FCMToken" :  recipient.user_ct_fcmtoken, 
            "UserId" : new String(recipientUserId)
        }
        //todo - remove user id might not be needed as we send the token already

		var callUrl = "https://demo.leadingedge.ro/CRM2020R1/CustomPages/LeadingEdge/PushServer/api/notification/send";
        var XHR = new ActiveXObject("Microsoft.XMLHTTP");
        
        XHR.open("POST", callUrl, false);
        XHR.setRequestHeader("Content-Type", "application/json");        
        XHR.setRequestHeader("APIKey", "dyd62MsFaJr0AD6n7ACTAtLWPlgR40RLrBdOrTYzwcA");
		XHR.onReadyStateChange = function () {
			if(XHR.readyState === 4 && XHR.status === 200) {
				//Response.Write(XHR.responseText); //"projects/mobilex-push-notifications/messages/0:1606224847799290%61319ad361319ad3"
				var _communication = CRM.FindRecord("Communication", "comm_communicationid = " + communication.RecordId);
				_communication.comm_status = "delivered";
				_communication.SaveChangesNoTls();
    
			}
		};
        XHR.send(JSON.stringify(pushData));  
        XHR = null;
    }


    var result = { id : communication.RecordId };
    Response.Write(JSON.stringify(result));

%>