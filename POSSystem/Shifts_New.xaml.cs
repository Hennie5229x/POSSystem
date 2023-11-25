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
    /// Interaction logic for Shifts_New.xaml
    /// </summary>
    public partial class Shifts_New : Window
    {
        public Shifts_New()
        {
            InitializeComponent();

            FillLookup();

            Validation_TextBox(tbx_StartingFloat);          
        }

        private void FillLookup()
        {
            //Users
            try
            {
                string ConString = ConfigurationManager.ConnectionStrings["ConString"].ConnectionString;
                //string CmdString = string.Empty;
                using (SqlConnection con = new SqlConnection(ConString))
                {
                    con.Open();

                    SqlCommand cmd = new SqlCommand("lkpUsers", con);
                    cmd.CommandType = CommandType.StoredProcedure;                    

                    SqlDataAdapter sda = new SqlDataAdapter(cmd);
                    DataTable dt = new DataTable("RoleGroupUsers");
                    sda.Fill(dt);
                    Cmbx.ItemsSource = dt.DefaultView;

                    con.Close();
                }
            }
            catch (Exception e)
            {
                MessageBox.Show(e.Message, "Error");
            }
        }

        private bool Validation_TextBox(TextBox TextBox)
        {
            decimal D_out = 0;

            if (TextBox.Text == "" || TextBox.Text == null)
            {
                TextBox.BorderBrush = System.Windows.Media.Brushes.Red;

                TextBox.ToolTip = "Field cannot be empty.";

                return false;
            }
            else if (Decimal.TryParse(TextBox.Text, out D_out) == false)
            {
                TextBox.BorderBrush = System.Windows.Media.Brushes.Red;

                TextBox.ToolTip = "Starting float needs to be numeric.";

                return false;
            }
            else
            {
                TextBox.BorderBrush = System.Windows.Media.Brushes.LightSlateGray;
                TextBox.ToolTip = null;

                return true;
            }
        }
       
        private void NewSHift()
        {
            if (Cmbx.SelectedValue == null)
            {
                MessageBox.Show("Please select a user.", "Error");
            }
            else if (!Validation_TextBox(tbx_StartingFloat))
            {
                MessageBox.Show("Starting float needs to be numeric.", "Error");
            }
            else
            { 
                try
                {
                    string ConString = ConfigurationManager.ConnectionStrings["ConString"].ConnectionString;
                    using (SqlConnection con = new SqlConnection(ConString))
                    {
                        con.Open();

                        SqlCommand cmd = new SqlCommand("stpShifts_Insert", con);

                        cmd.CommandType = CommandType.StoredProcedure;

                        cmd.Parameters.AddWithValue("@UserId", Cmbx.SelectedValue.ToString());
                        cmd.Parameters.AddWithValue("@StartFloat", Decimal.Parse(tbx_StartingFloat.Text));

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
        }

        private void btnNewShift_Click(object sender, RoutedEventArgs e)
        {
            NewSHift();            
        }

        private void BtnCancel_Click(object sender, RoutedEventArgs e)
        {
            this.Close();
        }
    }
}
