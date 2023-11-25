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
    /// Interaction logic for Terminals_Add.xaml
    /// </summary>
    public partial class Terminals_Add : Window
    {
        public Terminals_Add()
        {
            InitializeComponent();

            LookupFillPrinters();

            Validation_Empty(tbx_PrinterName);
            Validation_Empty(tbx_TerminalIP);
            Validation_Empty_ComboBox(cmbx_Printers, Border_ItemGroupCmbx);

        }

        private void LookupFillPrinters()
        {
            try
            {
                string ConString = ConfigurationManager.ConnectionStrings["ConString"].ConnectionString;
                using (SqlConnection con = new SqlConnection(ConString))
                {
                    con.Open();

                    SqlCommand cmd = new SqlCommand("lkpPrinters", con);
                    cmd.CommandType = CommandType.StoredProcedure;

                    //SqlDataReader reader = cmd.ExecuteReader();

                    SqlDataAdapter sda = new SqlDataAdapter(cmd);
                    DataTable dt = new DataTable("Printers");
                    sda.Fill(dt);
                    cmbx_Printers.ItemsSource = dt.DefaultView;
                    con.Close();
                }
            }
            catch (Exception e)
            {
                MessageBox.Show(e.Message, "Error");
            }
        }

        private void AddTerminal()
        {
            try
            {
                string ConString = ConfigurationManager.ConnectionStrings["ConString"].ConnectionString;
                using (SqlConnection con = new SqlConnection(ConString))
                {
                    con.Open();

                    SqlCommand cmd = new SqlCommand("stpTerminals_Insert", con);

                    cmd.CommandType = CommandType.StoredProcedure;

                    cmd.Parameters.AddWithValue("@TerminalName", tbx_PrinterName.Text);
                    cmd.Parameters.AddWithValue("@TerminalIP", tbx_TerminalIP.Text);
                    cmd.Parameters.AddWithValue("@PrinterId", cmbx_Printers.SelectedValue);
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
        private bool Validation_Empty_ComboBox(ComboBox cmbx, Border border)
        {
            if (cmbx.SelectedValue == null)
            {
                border.BorderBrush = System.Windows.Media.Brushes.Red;
                cmbx.ToolTip = "Drop down must have a value selected.";

                return false;
            }
            else
            {
                border.BorderBrush = System.Windows.Media.Brushes.LightSlateGray;
                cmbx.ToolTip = "";

                return true;
            }
        }

        private void Tbx_PrinterName_KeyUp(object sender, KeyEventArgs e)
        {
            Validation_Empty(tbx_PrinterName);
            Validation_Empty(tbx_TerminalIP);
            Validation_Empty_ComboBox(cmbx_Printers, Border_ItemGroupCmbx);
        }

        private void Tbx_TerminalIP_KeyUp(object sender, KeyEventArgs e)
        {
            Validation_Empty(tbx_PrinterName);
            Validation_Empty(tbx_TerminalIP);
            Validation_Empty_ComboBox(cmbx_Printers, Border_ItemGroupCmbx);
        }

        private void BtnAddTerminal_Click(object sender, RoutedEventArgs e)
        {
            AddTerminal();
        }

        private void BtnCancel_Click(object sender, RoutedEventArgs e)
        {
            this.Close();
        }

        private void Cmbx_Printers_DropDownClosed(object sender, EventArgs e)
        {
            Validation_Empty(tbx_PrinterName);
            Validation_Empty(tbx_TerminalIP);
            Validation_Empty_ComboBox(cmbx_Printers, Border_ItemGroupCmbx);
        }
    }
}
