using System;
using System.Collections.Generic;
using System.Data;
using System.Data.SqlClient;
using System.Linq;
using System.Web;
using System.Web.UI.HtmlControls;

namespace btnet
{
    //Database functions
    public class dbf
    {
        public static void Default_CheckDB(HtmlGenericControl msg)
        {
            // see if the connection string works
            try
            {
                // Intentionally getting an extra connection here so that we fall into the right "catch"
                SqlConnection conn = DbUtil.get_sqlconnection();
                conn.Close();

                try
                {
                    DbUtil.execute_nonquery("select count(1) from users");

                }
                catch (SqlException e1)
                {
                    Util.write_to_log(e1.Message);
                    Util.write_to_log(Util.get_setting("ConnectionString", "?"));
                    msg.InnerHtml = "Unable to find \"bugs\" table.<br>"
                    + "Click to <a href=install.aspx>setup database tables</a>";
                }

            }
            catch (SqlException e2)
            {
                msg.InnerHtml = "Unable to connect.<br>"
                + e2.Message + "<br>"
                + "Check Web.config file \"ConnectionString\" setting.<br>"
                + "Check also README.html<br>"
                + "Check also <a href=http://sourceforge.net/projects/btnet/forums/forum/226938>Help Forum</a> on Sourceforge.";
            }
        }

        //Function cancelled
        public static bool ViewAttachment(string sql, string bp_id)
        {
            using (SqlCommand cmd = new SqlCommand(sql))
            {
                cmd.Parameters.AddWithValue("@bp_id", bp_id);

                // Use an SqlDataReader so that we can write out the blob data in chunks.

                using (SqlDataReader reader = DbUtil.execute_reader(cmd, CommandBehavior.CloseConnection | CommandBehavior.SequentialAccess))
                {
                    if (reader.Read()) // Did we find the content in the database?
                    {
                        return true;
                    }
                }
            }
            return false;
        }
    }
}