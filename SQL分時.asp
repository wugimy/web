<!-- 這是存取資料庫的函式 -->
<!-- #include virtual="/config.inc" -->

<%
Function get_json(SQL)
	'開啟資料庫
	Set cnn = Server.CreateObject("ADODB.Connection")
	cnn.Open mysql_connection
    set rs=server.createobject("adodb.Recordset")
    rs.Open SQL,cnn
    json = "["
    While Not rs.EOF	' 判斷是否過了最後一筆
		If json <> "[" Then json = json & ","
		json = json & "{"
    	For i = 0 to rs.Fields.Count-1
			If i > 0 Then json =json & ","
			t = rs(i)
			If t <> "" Then
				t = Replace(t,vbCrLf,"\n")
				t = Replace(t,"""","\""")
			End If
            json = json & """" & rs(i).Name & """:""" & t & """"
    	Next
		json = json & "}"
    rs.MoveNext	' 移到下一筆
    Wend
	json = json & "]"
    rs.Close
    set rs = nothing
	'關閉資料庫
	cnn.Close
	set cnn = nothing
	get_json = json
End Function
%>

<script>
<%
SQL = "select B.*,CVD,IEX from (select floor(TIMESTAMPDIFF(SECOND,date(LOGOFF_TIME),LOGOFF_TIME)/1800) as HALF_HOUR,sum(case when EQP_ID like '%CVD%' then PROCESS_SHEET_QTY else 0 end) as CVD,sum(case when EQP_ID like '%IEX%' then PROCESS_SHEET_QTY else 0 end) as IEX from l5ab_lot_oper where MFG_DAY=(CURDATE()-INTERVAL 2 DAY) and EQP_ID like '" & FAB & "8%' group by floor(TIMESTAMPDIFF(SECOND,date(LOGOFF_TIME),LOGOFF_TIME)/1800)) A right outer join (select SN as HALF_HOUR,case when SN < 15 or SN >= 45 Then 'green' when SN between 20 and 23 or SN between 26 and 33 then 'red' else 'orange' end as COLOR from just_sn where SN < 48) B on A.HALF_HOUR=B.HALF_HOUR"
json = get_json(SQL)
%>
json = <%=json%>;

data = [];
for(var i=0;i<json.length;i++){
	color = json[i]['COLOR'];
	y = parseFloat(json[i]['CVD']);
	data.push({color:color,y:y});
}
	container = 'test_bar_chart_' + c;
	document.write('<div class="col-sm-6">');
	show_card('test','<div style="height:250px;" id="' + container + '"></div>')
	document.write('</div>');
	Highcharts.chart(container, {
		title: {
			text: ''
		},
		series: [{type:'column',data: data}]
	});
</script>
