using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using System.Data;
using System.Web.UI.HtmlControls;

namespace btnet
{
    public partial class btnetui : System.Web.UI.MasterPage
    {
        protected void Page_Load(object sender, EventArgs e)
        {
            if (!Page.IsPostBack)
            {
                htmlLogo.Text = Util.context.Application["custom_logo"].ToString();

                //HtmlMeta tag = new HtmlMeta() { Name = "viewport", Content = "width=device-width, initial-scale=1.0" };
                //this.Page.Header.Controls.Add(tag);
            }
        }
    }
}