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
    /// Interaction logic for Suppliers_Update.xaml
    /// </summary>
    public partial class Suppliers_Update : Window
    {
        public Suppliers_Update(int _id)
        {
            InitializeComponent();

            Id = _id;
            SupplierValues();

        }
        private int Id;

        private void SupplierValues()
        {
            string CompanyName = null;
            string SupplierName = null;
            string BillToAddress = null;
            string ShipToAddress = null;
            string BillingInformation = null;
            string ContactPerson = null;
            string Telephone = null;
            string CellPhone = null;
            string Email = null;
            string VATNumber = null;           

            try
            {
                string ConString = ConfigurationManager.ConnectionStrings["ConString"].ConnectionString;
                //string CmdString = string.Empty;
                using (SqlConnection con = new SqlConnection(ConString))
                {
                    con.Open();

                    SqlCommand cmd = new SqlCommand("calcSuppliers_Values", con);
                    cmd.CommandType = CommandType.StoredProcedure;

                    cmd.Parameters.AddWithValue("@Id", Id);

                    SqlDataReader reader = cmd.ExecuteReader();

                    while (reader.Read())
                    {
                        CompanyName = reader["CompanyName"].ToString();
                        SupplierName = reader["SupplierName"].ToString();
                        BillToAddress = reader["BillToAddress"].ToString();
                        ShipToAddress = reader["ShipToAddress"].ToString();
                        BillingInformation = reader["BillingInformation"].ToString();
                        ContactPerson = reader["ContactPerson"].ToString();
                        Telephone = reader["Telephone"].ToString();
                        CellPhone = reader["CellPhone"].ToString();
                        Email = reader["Email"].ToString();
                        VATNumber = reader["VATNumber"].ToString();
                    }

                    con.Close();

                    tbx_CompanyName.Text = CompanyName;
                    tbx_SupplierName.Text = SupplierName;
                    tbx_BillToAddress.Text = BillToAddress;
                    tbx_ShipToAddress.Text = ShipToAddress;
                    tbx_BillingInformation.Text = BillingInformation;
                    tbx_ContactPerson.Text = ContactPerson;
                    tbx_Telephone.Text = Telephone;
                    tbx_CellPhone.Text = CellPhone;
                    tbx_Email.Text = Email;
                    tbx_VATNumber.Text = VATNumber;
                }
            }
            catch (Exception e)
            {
                MessageBox.Show(e.Message, "Error");
            }

        }

        private void UpdateSupplier()
        {
            try
            {
                string ConString = ConfigurationManager.ConnectionStrings["ConString"].ConnectionString;
                using (SqlConnection con = new SqlConnection(ConString))
                {
                    con.Open();

                    SqlCommand cmd = new SqlCommand("stpSuppliers_Update", con);

                    cmd.CommandType = CommandType.StoredProcedure;

                    cmd.Parameters.AddWithValue("@Id", Id);
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

        private void Btn_Back_Click(object sender, RoutedEventArgs e)
        {
            this.Close();
        }

        private void BtnUpdateSupplier_Click(object sender, RoutedEventArgs e)
        {
            UpdateSupplier();
        }
    }
}
