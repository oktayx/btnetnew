<%@ Page language="C#" MasterPageFile="~/btnet.Master"%>
<%@ Import Namespace="btnet" %>
<%@ Import Namespace="System.Data" %>
<%@ Import Namespace="System.Collections.Generic" %>


<asp:Content ID="Content1" ContentPlaceHolderID="head" runat="server">
<title id="titl" runat="server">btnet backup db</title>
<script type="text/javascript" language="JavaScript" src="sortable.js"></script>
</asp:Content>

<asp:Content ID="Content2" ContentPlaceHolderID="ContentPlaceHolder1" runat="server">
<% security.write_menu2(Response, "admin"); %>

<div class="col-lg-6 col-md-6">

<asp:DataGrid ID="MyDataGrid" runat="server" CssClass="table table-bordered table-striped" AutoGenerateColumns="false" OnItemCommand="my_button_click">
    <HeaderStyle CssClass="datah"></HeaderStyle>
    <ItemStyle></ItemStyle>
    <Columns>
        <asp:BoundColumn HeaderText="File" DataField="file" />
        <asp:HyperLinkColumn HeaderText="Download" Text="Download" DataNavigateUrlField="url"
            Target="_blank" />
        <asp:ButtonColumn HeaderText="Delete" ButtonType="LinkButton" Text="Delete" CommandName="dlt" />
    </Columns>
</asp:DataGrid>
<div class="err" id="msg" runat="server">&nbsp;</div>

</div>
<% Response.Write(Application["custom_footer"]); %>

</asp:Content>

<script language="C#" runat="server">

Security security;

string app_data_folder;    
    
///////////////////////////////////////////////////////////////////////
void Page_Load(Object sender, EventArgs e)
{
    
	Util.do_not_cache(Response);
	
	security = new Security();
	security.check_security( HttpContext.Current, Security.MUST_BE_ADMIN);

	titl.InnerText = Util.get_setting("AppTitle","BugTracker.NET") + " - "
		+ "manage logs";

    app_data_folder = HttpContext.Current.Server.MapPath(null);
    app_data_folder += "\\App_Data\\logs\\"; 
    
    if (!IsPostBack)
    {
        get_files();
    }
   
}

void get_files()
{
    string[] backup_files = System.IO.Directory.GetFiles(app_data_folder, "*.txt");

    if (backup_files.Length == 0)
    {
        MyDataGrid.Visible = false;
        return;
    }

    MyDataGrid.Visible = true;
    
    // sort the files
    ArrayList list = new ArrayList();
    list.AddRange(backup_files);
    list.Sort();

    DataTable dt = new DataTable();
    DataRow dr;

    dt.Columns.Add(new DataColumn("file", typeof(String)));
    dt.Columns.Add(new DataColumn("url", typeof(String)));

    for (int i = list.Count - 1; i != -1; i--)
    {
        dr = dt.NewRow();

        string just_file = System.IO.Path.GetFileName((string)list[i]);
        dr[0] = just_file;
        dr[1] = "download_file.aspx?which=log&filename=" + just_file;

        dt.Rows.Add(dr);
    }

    DataView dv = new DataView(dt);
    
    MyDataGrid.DataSource = dv;
    MyDataGrid.DataBind();
}
       
   
void my_button_click(object sender, DataGridCommandEventArgs e)
{
    if (e.CommandName == "dlt")
    {
        int i = e.Item.ItemIndex;
        string file = MyDataGrid.Items[i].Cells[0].Text;
        System.IO.File.Delete(app_data_folder + file);
        get_files();
    }
   
}

    
</script>
