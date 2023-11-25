using System;
using System.Collections.Generic;
using System.Configuration;
using System.Data;
using System.Data.SqlClient;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace POSSystem_Retail
{
    class ItemGroupButtons
    {

        public int GroupId;
        public string GroupName;
        public List<string> GroupNames = new List<string>();

        public ItemGroupButtons()
        {
            try
            {
                string ConString = ConfigurationManager.ConnectionStrings["ConString"].ConnectionString;
                using (SqlConnection con = new SqlConnection(ConString))
                {
                    con.Open();

                    SqlCommand cmd = new SqlCommand("stpItemGroupButtons_Select", con);
                    cmd.CommandType = CommandType.StoredProcedure;
                    cmd.Parameters.AddWithValue("@RowNum", 0);
                    SqlDataReader reader = cmd.ExecuteReader();

                    while (reader.Read())
                    {
                        GroupNames.Add(reader["GroupName"].ToString());
                    }

                    con.Close();
                }
            }
            catch (Exception e)
            {
                System.Windows.MessageBox.Show(e.Message, "Error");
            }
        }


        public ItemGroupButtons(int RowNum)
        {
            try
            {
                string ConString = ConfigurationManager.ConnectionStrings["ConString"].ConnectionString;
                using (SqlConnection con = new SqlConnection(ConString))
                {
                    con.Open();

                    SqlCommand cmd = new SqlCommand("stpItemGroupButtons_Select", con);
                    cmd.CommandType = CommandType.StoredProcedure;
                    cmd.Parameters.AddWithValue("@RowNum", RowNum);
                    SqlDataReader reader = cmd.ExecuteReader();

                    while (reader.Read())
                    {
                        GroupId = Int32.Parse(reader["Id"].ToString());
                        GroupName = reader["GroupName"].ToString();
                    }

                    con.Close();
                }
            }
            catch (Exception e)
            {
                System.Windows.MessageBox.Show(e.Message, "Error");
            }
        }

    }
}
