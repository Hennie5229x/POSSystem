using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using System.Configuration;
using System.Data;
using System.Data.SqlClient;

namespace POSSystem_Retail
{
    public partial class ItemButtons
    {
        public int ItemId;
        public string ButtonText;
        public string Font;
        public int FontSize;
        public string Hexa;

        public List<string> ItemNames = new List<string>();


        public ItemButtons(int GroupId)
        {
            try
            {
                string ConString = ConfigurationManager.ConnectionStrings["ConString"].ConnectionString;
                using (SqlConnection con = new SqlConnection(ConString))
                {
                    con.Open();

                    SqlCommand cmd = new SqlCommand("stpItemButtons_Select", con);
                    cmd.CommandType = CommandType.StoredProcedure;
                    cmd.Parameters.AddWithValue("@GroupId", GroupId);
                    cmd.Parameters.AddWithValue("@RowNum", 0);
                    SqlDataReader reader = cmd.ExecuteReader();

                    while (reader.Read())
                    {
                        ItemNames.Add(reader["ButtonText"].ToString());
                    }

                    con.Close();
                }
            }
            catch (Exception e)
            {
                System.Windows.MessageBox.Show(e.Message, "Error");
            }
        }


        public ItemButtons(int GroupId, int RowNum)
        {
            try
            {
                string ConString = ConfigurationManager.ConnectionStrings["ConString"].ConnectionString;
                using (SqlConnection con = new SqlConnection(ConString))
                {
                    con.Open();

                    SqlCommand cmd = new SqlCommand("stpItemButtons_Select", con);
                    cmd.CommandType = CommandType.StoredProcedure;
                    cmd.Parameters.AddWithValue("@GroupId", GroupId);
                    cmd.Parameters.AddWithValue("@RowNum", RowNum);
                    SqlDataReader reader = cmd.ExecuteReader();

                    while (reader.Read())
                    {
                        ItemId = Int32.Parse(reader["ItemId"].ToString());
                        ButtonText = reader["ButtonText"].ToString();
                        Font = reader["Font"].ToString();
                        FontSize = Int32.Parse(reader["FontSize"].ToString());
                        Hexa = reader["Hex"].ToString();
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
