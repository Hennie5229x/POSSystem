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
    /// Interaction logic for VoidDocument.xaml
    /// </summary>
    public partial class VoidDocument : Window
    {
        public VoidDocument(int doc_id)
        {
            InitializeComponent();

            DocId = doc_id;

        }
        /*---------*/
        int DocId = 0;
        /*---------*/


        private void Doc_Void()
        {

            try
            {
                string ConString = ConfigurationManager.ConnectionStrings["ConString"].ConnectionString;
                //string CmdString = string.Empty;
                using (SqlConnection con = new SqlConnection(ConString))
                {
                    con.Open();

                    SqlCommand cmd = new SqlCommand("stpPOS_Doc_VoidDocument", con);
                    cmd.CommandType = CommandType.StoredProcedure;

                    cmd.Parameters.AddWithValue("@DocumentId", DocId);                    

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
            Doc_Void();
        }

        private void Btn_Canceel_Click(object sender, RoutedEventArgs e)
        {
            this.Close();
        }
    }
}
