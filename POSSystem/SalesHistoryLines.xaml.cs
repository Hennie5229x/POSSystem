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


namespace POSSystem_Manager
{
    /// <summary>
    /// Interaction logic for Shifts.xaml
    /// </summary>
    public partial class SalesHistoryLines : Window
    {
        public SalesHistoryLines(int DocId = -1)
        {
            InitializeComponent();
            FillDataGrid(DocId);
        }
              
        
        public void FillDataGrid(int DocId)
        {   
            
            string ConString = ConfigurationManager.ConnectionStrings["ConString"].ConnectionString;
            using (SqlConnection con = new SqlConnection(ConString))
            {
                SqlCommand cmd = new SqlCommand("stpSalesHistoryLines_Select", con);
                cmd.CommandType = CommandType.StoredProcedure;

                cmd.Parameters.AddWithValue("@DocId", DocId);                

                SqlDataAdapter sda = new SqlDataAdapter(cmd);
                DataTable dt = new DataTable("SalesHistoryLines");
                sda.Fill(dt);
                grdSalesHistoryLines.ItemsSource = dt.DefaultView;
            }
        }

        

        
    }
}
