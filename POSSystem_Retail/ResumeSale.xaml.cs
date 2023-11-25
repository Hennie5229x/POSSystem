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
    /// Interaction logic for ResumeSale.xaml
    /// </summary>
    public partial class ResumeSale : Window
    {
        public ResumeSale(string user_id, int terminal_id)
        {
            InitializeComponent();

            UserId = user_id;
            TerminalId = terminal_id;
        }

        /*---------*/
        string UserId = "";
        int TerminalId = 0;
        /*---------*/

        private void Doc_ResumeSale()
        {

            try
            {
                string ConString = ConfigurationManager.ConnectionStrings["ConString"].ConnectionString;
                //string CmdString = string.Empty;
                using (SqlConnection con = new SqlConnection(ConString))
                {
                    con.Open();

                    SqlCommand cmd = new SqlCommand("stpPOS_Doc_ResumeSale", con);
                    cmd.CommandType = CommandType.StoredProcedure;

                    cmd.Parameters.AddWithValue("@UserId", UserId);
                    cmd.Parameters.AddWithValue("@TerminalId", TerminalId);

                    cmd.ExecuteNonQuery();

                    con.Close();

                    this.Close();

                }
            }
            catch (Exception e)
            {
                //MessageBox.Show(e.Message, "Error");
                ErrorDialog errorDialog = new ErrorDialog("Error", e.Message);
                errorDialog.ShowDialog();
            }

        }


        private void Btn_OK_Click(object sender, RoutedEventArgs e)
        {
            Doc_ResumeSale();
        }

        private void Btn_Canceel_Click(object sender, RoutedEventArgs e)
        {
            this.Close();
        }
    }
}
