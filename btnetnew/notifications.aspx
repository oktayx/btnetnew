<%@ Page language="C#" MasterPageFile="~/btnetui.Master"%>
<%@ Import Namespace="btnet" %>
<%@ Import Namespace="System.Data" %>
<%@ Import Namespace="System.Collections.Generic" %>


<asp:Content ID="Content1" ContentPlaceHolderID="head" runat="server">
<title id="titl" runat="server">btnet queued notifications</title>
<script type="text/javascript" language="JavaScript" src="sortable.js"></script>
</asp:Content>

<asp:Content ID="Content2" ContentPlaceHolderID="ContentPlaceHolder1" runat="server">
<% security.write_menu2(Response, "admin"); %>
    
<div style="width: 600px;" class="well smallnote">

Email notifications are put into a table into the database and then the system attempts to send them.
If the system fails to send the notification, it records the reason for the failure with the row.
<br><br>
The system makes 3 attempts to send the notification.  After the 3rd attempt,
you can either give up and delete the unsent notifications
or you can reset the retry count and let the system continue trying.

</div>

<p></p>
<div class=align>
<a href="edit_queued_notifications.aspx?actn=delete&ses=<% Response.Write(ses); %>" >Delete unsent notifications</a>
<br>
<br>
<a href="edit_queued_notifications.aspx?actn=reset&ses=<% Response.Write(ses); %>" >Reset retry count to zero</a>
<br>
<br>
<a href="edit_queued_notifications.aspx?actn=resend&ses=<% Response.Write(ses); %>" >Try to resend</a>
<br>
<br>

<%

if (ds.Tables[0].Rows.Count > 0)
{
	SortableHtmlTable.create_from_dataset(
		Response, ds, "", "");

}
else
{
	Response.Write ("No queued email notifications in the database.");
}

%>
</div>
<% Response.Write(Application["custom_footer"]); %>
</asp:Content>


<script language="C#" runat="server">

DataSet ds;

Security security;
string ses;

void Page_Load(Object sender, EventArgs e)
{

	Util.do_not_cache(Response);
	
	security = new Security();
	security.check_security( HttpContext.Current, Security.MUST_BE_ADMIN);

	titl.InnerText = Util.get_setting("AppTitle","BugTracker.NET") + " - "
		+ "queued notifications";

	ds = DbUtil.get_dataset(
		@"select
		qn_id [id],
		qn_date_created [date created],
		qn_to [to],
		qn_bug [bug],
		qn_status [status],
		qn_retries [retries],
		qn_last_exception [last error]
		from queued_notifications
		order by id;");

	ses = (string) Session["session_cookie"];
}


</script>