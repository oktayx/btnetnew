<%@ Page Language="C#" MasterPageFile="~/btnetui.Master" %>

<%@ Import Namespace="btnet" %>
<%@ Import Namespace="System.Data" %>
<%@ Import Namespace="System.Collections.Generic" %>


<asp:Content ID="Content1" ContentPlaceHolderID="head" runat="server">
    <title id="titl" runat="server">btnet backup db</title>
</asp:Content>

<asp:Content ID="Content2" ContentPlaceHolderID="ContentPlaceHolder1" runat="server">
    <% security.write_menu2(Response, "admin"); %>

    <div class="align">
        <table border="0">
            <tr>
                <td>
                    <asp:DataGrid ID="MyDataGrid" runat="server" BorderColor="black" CssClass="datat"
                        CellPadding="3" AutoGenerateColumns="false" OnItemCommand="my_button_click">
                        <HeaderStyle CssClass="datah"></HeaderStyle>
                        <ItemStyle CssClass="datad"></ItemStyle>
                        <Columns>
                            <asp:BoundColumn HeaderText="File" DataField="file" />
                            <asp:HyperLinkColumn HeaderText="Download" Text="Download" DataNavigateUrlField="url"
                                Target="_blank" />
                            <asp:ButtonColumn HeaderText="Delete" ButtonType="LinkButton" Text="Delete" CommandName="dlt" />
                        </Columns>
                    </asp:DataGrid>
                    <div class="err" id="msg" runat="server">&nbsp;</div>

                    <div>
                        <input type="submit" value="Backup Database Now" class="btn btn-info" runat="server" onserverclick="on_backup" style="width: 200px; height: 50px;"></div>


                    <p>&nbsp;</p>
                    <p>&nbsp;</p>
                    You can use SQL like this to restore your backup to your own server:
                    <pre>

RESTORE DATABASE your_database
   FROM DISK = 'C:\path\to\your\your_backup_file.bak'
   WITH 
      MOVE 'btnet' TO 'C:\path\to\where\you\want\your_db_data.mdf' ,
      MOVE 'btnet_log'  TO 'C:\path\to\where\you\want\your_db_log.ldf', REPLACE

</pre>


        </table>
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
        security.check_security(HttpContext.Current, Security.MUST_BE_ADMIN);

        titl.InnerText = Util.get_setting("AppTitle", "BugTracker.NET") + " - "
            + "backup db";

        app_data_folder = HttpContext.Current.Server.MapPath(null);
        app_data_folder += "\\App_Data\\";

        if (!IsPostBack)
        {
            get_files();
        }

    }

    void get_files()
    {
        string[] backup_files = System.IO.Directory.GetFiles(app_data_folder, "*.bak");

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

        for (int i = 0; i < list.Count; i++)
        {
            dr = dt.NewRow();

            string just_file = System.IO.Path.GetFileName((string)list[i]);
            dr[0] = just_file;
            dr[1] = "download_file.aspx?which=backup&filename=" + just_file;

            dt.Rows.Add(dr);
        }

        DataView dv = new DataView(dt);

        MyDataGrid.DataSource = dv;
        MyDataGrid.DataBind();
    }


    void on_backup(Object sender, EventArgs e)
    {
        string date = DateTime.Now.ToString("yyyyMMdd_HHmmss");
        string db = (string)DbUtil.execute_scalar("select db_name()");
        string backup_file = app_data_folder + "db_backup_" + date + ".bak";
        string sql = "backup database " + db + " to disk = '" + backup_file + "'";
        DbUtil.execute_nonquery(sql);
        get_files();
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
