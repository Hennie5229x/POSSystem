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
using POSSystem;

namespace POSSystem_Manager
{
   
    public partial class Denominations : Window
    {
        public Denominations()
        {
            InitializeComponent();

            FillDataGrid();

        }

        private void FillDataGrid()
        {
            try
            {
                string ConString = ConfigurationManager.ConnectionStrings["ConString"].ConnectionString;
                using (SqlConnection con = new SqlConnection(ConString))
                {
                    SqlCommand cmd = new SqlCommand("stpDenominations_Select", con);

                    cmd.CommandType = CommandType.StoredProcedure;

                    SqlDataAdapter sda = new SqlDataAdapter(cmd);
                    DataTable dt = new DataTable("Denomiations");
                    sda.Fill(dt);
                    grdDenoms.ItemsSource = dt.DefaultView;
                }
            }
            catch (Exception e)
            {
                MessageBox.Show(e.Message, "Error");
            }
        }

        private void ResetDenominations()
        {
            try
            {
                string ConString = ConfigurationManager.ConnectionStrings["ConString"].ConnectionString;
                using (SqlConnection con = new SqlConnection(ConString))
                {
                    con.Open();

                    SqlCommand cmd = new SqlCommand("stpDenomiations_Reset", con);

                    cmd.CommandType = CommandType.StoredProcedure;

                    cmd.Parameters.AddWithValue("@UserId", UserId.User_Id);

                    cmd.ExecuteNonQuery();

                    con.Close();

                    FillDataGrid();
                }

            }
            catch (Exception e)
            {
                MessageBox.Show(e.Message, "Error");
            }
        }
    

        private void btn_AddDenomination_Click(object sender, RoutedEventArgs e)
        {
            //Add
            Denominations_Add denominations_Add = new Denominations_Add();
            denominations_Add.ShowDialog();
            this.FillDataGrid();
        }

        private void btn_ResetDenominations_Click(object sender, RoutedEventArgs e)
        {
            MessageBoxResult messageBoxResult = System.Windows.MessageBox.Show("Are you sure you want to reset ?", "Reset Confirmation", System.Windows.MessageBoxButton.YesNo);

            if (messageBoxResult == MessageBoxResult.Yes)
            {
                ResetDenominations();                
            }
        }
    }
}
