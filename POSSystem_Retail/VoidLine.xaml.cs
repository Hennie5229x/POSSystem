using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using System.Windows;
using System.Windows.Controls;
using System.Windows.Data;
using System.Windows.Documents;
using System.Windows.Input;
using System.Windows.Media;
using System.Windows.Media.Imaging;
using System.Windows.Shapes;
using System.Configuration;
using System.Data;
using System.Data.SqlClient;


namespace POSSystem_Retail
{
    /// <summary>
    /// Interaction logic for VoidLine.xaml
    /// </summary>
    public partial class VoidLine : Window
    {
        public VoidLine(int doc_id, int line_id)
        {
            InitializeComponent();

            DocId = doc_id;
            LineId = line_id;

            GetLineValues();

        }

        /*--------------*/
        int DocId = 0;
        int LineId = 0;
        string ItemName = "";
        string Qty = "";

        /*--------------*/


        private void GetLineValues()
        {
            
            try
            {
                string ConString = ConfigurationManager.ConnectionStrings["ConString"].ConnectionString;
                //string CmdString = string.Empty;
                using (SqlConnection con = new SqlConnection(ConString))
                {
                    con.Open();

                    SqlCommand cmd = new SqlCommand("calcPOSDocLines_Values", con);
                    cmd.CommandType = CommandType.StoredProcedure;

                    cmd.Parameters.AddWithValue("@DocId", DocId);
                    cmd.Parameters.AddWithValue("@LineId", LineId);

                    SqlDataReader reader = cmd.ExecuteReader();

                    while (reader.Read())
                    {
                        ItemName = reader["ItemName"].ToString();
                        Qty = reader["Quantity"].ToString();
                    }

                    con.Close();
                    
                    textBlock.Text = "Item: " + ItemName;                   

                }
            }
            catch (Exception e)
            {
                MessageBox.Show(e.Message, "Error");
            }

        }

        private void Doc_VoidLine()
        {

            try
            {
                string ConString = ConfigurationManager.ConnectionStrings["ConString"].ConnectionString;
                //string CmdString = string.Empty;
                using (SqlConnection con = new SqlConnection(ConString))
                {
                    con.Open();

                    SqlCommand cmd = new SqlCommand("stpPOS_Doc_VoidLine", con);
                    cmd.CommandType = CommandType.StoredProcedure;

                    cmd.Parameters.AddWithValue("@DocId", DocId);
                    cmd.Parameters.AddWithValue("@LineId", LineId);

                    cmd.ExecuteNonQuery();

                    con.Close();

                    this.Close();     
                   
                }
            }
            catch (Exception e)
            {
                MessageBox.Show(e.Message, "Error");
            }

        }


        private void Btn_Canceel_Click(object sender, RoutedEventArgs e)
        {
            GlobalVaraibles.VoidLine_Canceled = true;
            this.Close();
        }

        private void Btn_OK_Click(object sender, RoutedEventArgs e)
        {
            GlobalVaraibles.VoidLine_Canceled = false;
            Doc_VoidLine();
        }
    }
}
