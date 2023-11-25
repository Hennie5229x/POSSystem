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
    /// <summary>
    /// Interaction logic for Printers_Add.xaml
    /// </summary>
    public partial class Printers_Add : Window
    {
        public Printers_Add()
        {
            InitializeComponent();

            Validation_Empty(tbx_PrinterName);
        }

        private void AddPrinter()
        {
            try
            {
                string ConString = ConfigurationManager.ConnectionStrings["ConString"].ConnectionString;
                using (SqlConnection con = new SqlConnection(ConString))
                {
                    con.Open();

                    SqlCommand cmd = new SqlCommand("stpPrinters_Insert", con);

                    cmd.CommandType = CommandType.StoredProcedure;

                    cmd.Parameters.AddWithValue("@PrinterName", tbx_PrinterName.Text);
                    cmd.Parameters.AddWithValue("@PrinterDescription", tbx_Description.Text);
                    cmd.Parameters.AddWithValue("@UserId", UserId.User_Id);

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

        private bool Validation_Empty(TextBox TextBox)
        {
            if (TextBox.Text == "" || TextBox.Text == null)
            {
                TextBox.BorderBrush = System.Windows.Media.Brushes.Red;

                TextBox.ToolTip = "Field cannot be empty.";

                return false;
            }
            else
            {
                TextBox.BorderBrush = System.Windows.Media.Brushes.LightSlateGray;
                TextBox.ToolTip = "";

                return true;
            }
        }

        private void Tbx_PrinterName_KeyUp(object sender, KeyEventArgs e)
        {
            Validation_Empty(tbx_PrinterName);
        }

        private void BtnAddPrinter_Click(object sender, RoutedEventArgs e)
        {
            if (!Validation_Empty(tbx_PrinterName))
            {
                MessageBox.Show("Group Name cannot be empty", "Error");
            }
            else
            {
                AddPrinter();
            }
        }

        private void BtnCancel_Click(object sender, RoutedEventArgs e)
        {
            this.Close();
        }
    }
}
