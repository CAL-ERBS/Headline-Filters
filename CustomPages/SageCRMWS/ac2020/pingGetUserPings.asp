<!-- #include file ="sagecrm.js" -->

<!-- #include file ="helpers.js" -->
<%    

//no longer used
so breaking with this code

    var pings = [];
    var record = CRM.FindRecord("Communication,vPings", "comm_type='ping' AND cmli_comm_userid=" + Request.QueryString("userId"));
    record.OrderBy = "Comm_DateTime DESC";
    var i = 0;
    while(!record.eof && i < 10) {  
        var sender = 
        pings.push({ 
            id : record.RecordId, 
            title : record("comm_subject"), 
            body :  record("comm_note"), 
            entity: record("comm_action"),   
            sender : record("user_fullname"),
            link : record("comm_description"), 
            tileicon : getTileIcon(record("comm_action")),
            tilecolor: getTileColour(record("comm_action")),
            dateSent: new Date(record("comm_datetime")).getTime(),
            readStatus : record("comm_status") ,
            show : record("comm_status") == 'read'
        });
        i++;
        record.NextRecord();
    }

    Response.Write(JSON.stringify(pings));
%>