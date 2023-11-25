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

namespace POSSystem
{
    /// <summary>
    /// Interaction logic for Suppliers_Add.xaml
    /// </summary>
    public partial class Suppliers_Add : Window
    {
        public Suppliers_Add()
        {
            InitializeComponent();

            Validation_Empty(tbx_SupplierName);
            Validation_Empty(tbx_CompanyName);
        }

        private void AddSupplier()
        {
            try
            {
                string ConString = ConfigurationManager.ConnectionStrings["ConString"].ConnectionString;
                using (SqlConnection con = new SqlConnection(ConString))
                {
                    con.Open();

                    SqlCommand cmd = new SqlCommand("stpSuppliers_Insert", con);

                    cmd.CommandType = CommandType.StoredProcedure;

                    cmd.Parameters.AddWithValue("@CompanyName", tbx_CompanyName.Text);
                    cmd.Parameters.AddWithValue("@SupplierName", tbx_SupplierName.Text);
                    cmd.Parameters.AddWithValue("@BillToAddress", tbx_BillToAddress.Text);
                    cmd.Parameters.AddWithValue("@ShipToAddress", tbx_ShipToAddress.Text);
                    cmd.Parameters.AddWithValue("@BillingInformation", tbx_BillingInformation.Text);
                    cmd.Parameters.AddWithValue("@ContactPerson", tbx_ContactPerson.Text);
                    cmd.Parameters.AddWithValue("@Telephone", tbx_Telephone.Text);
                    cmd.Parameters.AddWithValue("@CellPhone", tbx_CellPhone.Text);
                    cmd.Parameters.AddWithValue("@Email", tbx_Email.Text);
                    cmd.Parameters.AddWithValue("@VATNumber", tbx_VATNumber.Text);
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

        private void Tbx_SupplierName_KeyUp(object sender, KeyEventArgs e)
        {
            Validation_Empty(tbx_SupplierName);
            Validation_Empty(tbx_CompanyName);
        }

        private void Btn_Back_Click(object sender, RoutedEventArgs e)
        {
            this.Close();
        }

        private void BtnAddSupplier_Click(object sender, RoutedEventArgs e)
        {
            if(!Validation_Empty(tbx_SupplierName) || !Validation_Empty(tbx_CompanyName))
            {
                MessageBox.Show("Please fill in required fields","Error");
            }
            else
            {
                AddSupplier();
            }
        }

        private void Tbx_CompanyName_KeyUp(object sender, KeyEventArgs e)
        {
            Validation_Empty(tbx_SupplierName);
            Validation_Empty(tbx_CompanyName);
        }
    }
}
