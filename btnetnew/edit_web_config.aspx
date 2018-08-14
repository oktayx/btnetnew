<%@ Page language="C#" MasterPageFile="~/btnet.Master"%>
<%@ Import Namespace="btnet" %>
<%@ Import Namespace="System.Data" %>
<%@ Import Namespace="System.Collections.Generic" %>


<asp:Content ID="Content1" ContentPlaceHolderID="head" runat="server">
<title id="titl" runat="server">btnet edit web config</title>
<script language="Javascript" type="text/javascript" src="edit_area/edit_area_full.js"></script>

<script>
    editAreaLoader.init({
        id: "myedit"	// id of the textarea to transform
			, start_highlight: true	// if start with highlight
			, toolbar: "search, go_to_line, undo, redo, help"
			, browsers: "all"
			, language: "en"
			, syntax: "sql"
			, allow_toggle: false
			, min_width: 800
			, min_height: 400
    });

    function load_custom_file() {
        var sel = document.getElementById("which")
        window.location = "edit_custom_html.aspx?which=" + sel.options[sel.selectedIndex].value
    }    
</script>	

</asp:Content>

<asp:Content ID="Content2" ContentPlaceHolderID="ContentPlaceHolder1" runat="server">
<% security.write_menu2(Response, "admin"); %>


<div class=align><table border=0 style="margin-left:20px; margin-top:20px; width:80%;"><tr><td>

<textarea id="myedit" runat="server" style="width:100%"></textarea>
<p></p>

<div class="err" id="msg" runat="server">&nbsp;</div>

<div><input type=submit value="Save" class="btn">
    &nbsp;&nbsp;
    <span style="border: solid red 1px; padding: 2px; margin: 3px; color: red; font-size: 9px;">
    Be careful!  Web.config is easy to break!
    </span><br>
</div>

</table>
</div>
<% Response.Write(Application["custom_footer"]); %>


</asp:Content>

<script language="C#" runat="server">

Security security;
    
///////////////////////////////////////////////////////////////////////
void Page_Load(Object sender, EventArgs e)
{

    
	Util.do_not_cache(Response);
	
	security = new Security();
	security.check_security( HttpContext.Current, Security.MUST_BE_ADMIN);

	titl.InnerText = Util.get_setting("AppTitle","BugTracker.NET") + " - "
		+ "edit Web.config";

    string path = HttpContext.Current.Server.MapPath(null);
    path += "\\Web.config";

    if (!IsPostBack)
    {
        System.IO.StreamReader sr = System.IO.File.OpenText(path);
        myedit.Value = sr.ReadToEnd();
        sr.Close();
        sr.Dispose();
        msg.InnerHtml = "&nbsp;";
    }
    else
    {
        System.Xml.XmlDocument doc = new System.Xml.XmlDocument();
        System.IO.StringReader stringReader = new System.IO.StringReader(myedit.Value);
        try
        {
            doc.Load(stringReader);
            System.IO.StreamWriter sw = System.IO.File.CreateText(path);
            sw.Write(myedit.Value);
            sw.Close();
            sw.Dispose();
            msg.InnerHtml = "Web.config was saved.";
        }
        catch (Exception ex)
        {
            msg.InnerHtml = "ERROR:" + ex.Message;        
        }
    }

    
}

</script>
