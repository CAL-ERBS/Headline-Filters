<!-- #include file ="sagecrm.js" -->


<%    
    var users = [];
    var record = CRM.FindRecord("Users,vUsers", "user_fullname is not null and user_fullname<>''");
    record.OrderBy = "User_fullname ASC";
    while(!record.eof) {
        token  = Defined(record.item("user_ct_fcmtoken")) ?  record.item("user_ct_fcmtoken") : "";
        users.push({ id : record.RecordId, name : record("user_fullname"), fcmtoken :  token });
        record.NextRecord();
    }

    Response.Write(JSON.stringify(users));
%>