<%@ Page Language="C#" MasterPageFile="~/btnetui.Master" %>

<%@ Import Namespace="btnet" %>
<%@ Import Namespace="System.Data" %>
<%@ Import Namespace="System.Collections.Generic" %>


<asp:Content ID="Content1" ContentPlaceHolderID="head" runat="server">
    <title id="titl" runat="server">btnet dashboard</title>

    <style>
        body {
            background: #ffffff;
        }

        .panel {
            background: #ffffff;
            border: 3px solid #cccccc;
            padding: 10px;
            margin-bottom: 10px;
        }

        iframe {
            border: 1px solid white;
            width: 100%;
            min-width: 300px;
            min-height: 300px;
        }
    </style>

    <script type="text/javascript">
        function changeIframe(cb) {
            var frames = document.getElementsByTagName("iframe");
            var f = null;
            //document.getElementById("lblToggle").innerHTML = cb.checked ? "Collapse" : "Expand";

            if (cb.checked) {

                for (i = 0; i < frames.length; i++) {
                    f = frames[i];
                    f.style.height = f.contentDocument.body.offsetHeight + "px";
                    f.contentDocument.body.style.overflow = "hidden";
                }
            }
            else {
                for (i = 0; i < frames.length; i++) {
                    f = frames[i];
                    f.style.height = "300px";
                    f.contentDocument.body.style.overflow = "auto";
                }
            }
        }
    </script>

</asp:Content>

<asp:Content ID="Content2" ContentPlaceHolderID="ContentPlaceHolder1" runat="server">
    <% security.write_menu2(Response, "reports"); %>

    <div>
        <% if (security.user.is_guest) /* no dashboard */
            { %>
        <span class="disabled_link">edit dashboard not available to "guest" user</span>
        <% }
            else
            { %>
        <span><a href="edit_dashboard.aspx">edit dashboard</a></span>
        <% } %>
        <span class="pull-right">
            <input id="chkToggle" type="checkbox" onchange="changeIframe(this);" value="Check" />
            <label id="lblToggle" for="chkToggle">Expand</label>
        </span>
    </div>

    <table class="table" style="border: 0px; padding: 10px;">
        <tr>

            <td valign="top">&nbsp;<br>

                <% write_column(1); %>

            <td valign="top">&nbsp;<br>

                <% write_column(2); %>

            <td valign="top">&nbsp;<br>

                <% write_column(3); %>
    </table>

    <% Response.Write(Application["custom_footer"]); %>
</asp:Content>


<script language="C#" runat="server">


    Security security;
    DataSet ds = null;

    ///////////////////////////////////////////////////////////////////////
    void Page_Load(Object sender, EventArgs e)
    {

        Util.do_not_cache(Response);

        security = new Security();
        security.check_security(HttpContext.Current, Security.ANY_USER_OK);

        titl.InnerText = Util.get_setting("AppTitle", "BugTracker.NET") + " - "
            + "dashboard";

        if (security.user.is_admin || security.user.can_use_reports)
        {
            //
        }
        else
        {
            Response.Write("You are not allowed to use this page.");
            Response.End();
        }

        string sql = @"
select ds.*, rp_desc
from dashboard_items ds
inner join reports on rp_id = ds_report
where ds_user = $us
order by ds_col, ds_row";

        sql = sql.Replace("$us", Convert.ToString(security.user.usid));
        ds = DbUtil.get_dataset(sql);

    }

    void write_column(int col)
    {
        int iframe_id = 0;

        foreach (DataRow dr in ds.Tables[0].Rows)
        {
            if ((int)dr["ds_col"] == col)
            {
                if ((string)dr["ds_chart_type"] == "data")
                {
                    iframe_id++;
                    Response.Write("\n<div class=panel>");
                    Response.Write("\n<iframe frameborder='0' src=view_report.aspx?view=data&id="
                        + dr["ds_report"]
                        // this didn't work
                        //+ "&parent_iframe="
                        //+ Convert.ToString(iframe_id)
                        //+ " id="
                        //+ Convert.ToString(iframe_id)
                        + "></iframe>");
                    Response.Write("\n</div>");
                }
                else
                {
                    Response.Write("\n<div class='panel'>");
                    Response.Write("\n<img src='view_report.aspx?scale=2&view=" + dr["ds_chart_type"] + "&id=" + dr["ds_report"] + "'>");
                    Response.Write("\n</div>");
                }
            }
        }

    }

</script>
