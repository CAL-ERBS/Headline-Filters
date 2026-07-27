<%
//merge functions


//does a replace of ##fields with record field value
function doMerge(str, hashFields, _record, pre, entity) {	
	var s = str;	
	var v="";
	pre=pre.toLowerCase();
	for (var j =0; j< hashFields.length; j++) {
		fieldName = hashFields[j];	
		if (fieldName.indexOf(pre) == 0 ) {	
			if (endsWith(hashFields[j].toLowerCase(),"_raw"))
			{
				try {
					fieldName=hashFields[j].substring(0,hashFields[j].length-4);
					v = Defined(_record.item(fieldName)) ? _record.item(fieldName) : "";						
				} catch (ex) {
					//field found in the template does not exist on the record
					v = "#" + fieldName + "#";
				}	
				s = s.replace("#" + hashFields[j] + "#", v);	
			} else 
			if (hashFields[j].toLowerCase() == fieldName) {
				try {
					v = mergeGetDisplayfield(entity, fieldName, _record);
					//v = Defined(_record(fieldName)) ? _record(fieldName) : "";				
				} catch (ex) {
					//field found in the template does not exist on the record
					v = "#" + fieldName + "#";
				}				
				s = s.replace("#" + hashFields[j] + "#", v);							
			}
		}
	}	
	return s;
}

function getMergeFieldObject(name)
{
	var res={
		name:'',
		order:0,
		newline:false,
		type:'',
		lookup:'',
		viewfields:''
	};
	var _fieldsql="select distinct ColP_ColName, ColP_EntryType, ColP_LookupFamily, Colp_ssViewField "+
					"from Custom_Edits where 4545=4545 and ColP_ColName='"+name+"'";
    //Response.Write(_fieldsql);
	var _q=CRM.CreateQueryObj(_fieldsql);
	_q.SelectSQL();
	if (!q.eof)
	{
		res.name=_q.FieldValue("ColP_ColName");
		res.type=_q.FieldValue("ColP_EntryType");
		res.lookup=_q.FieldValue("ColP_LookupFamily");
		res.viewfields=_q.FieldValue("Colp_ssViewField");
	}
	return res;
}

function mergeGetDisplayfield(entity,fieldname, _record)
{
	var fieldrawvalue=_record.item(fieldname);
	var _fieldObj=getMergeFieldObject(fieldname);
	if (_fieldObj==null)
		return '';
	return getSearchListFieldsData(entity,_fieldObj,fieldrawvalue,false,false);
}

function getHashFields(str) {
	retArr = [];
	var re  = /#(\w*)#/g; 
	var m; 
	while ((m = re.exec(str)) !== null) {
		if (m.index === re.lastIndex) {
			re.lastIndex++;
		}
		retArr.push(m[0].replace(/#/g, ""));	
	}
	return retArr;
}

%>