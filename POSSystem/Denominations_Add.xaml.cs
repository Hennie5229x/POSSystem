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
   
    public partial class Denominations_Add : Window
    {
        public Denominations_Add()
        {
            InitializeComponent();

            FillLookup();

            Validation_Empty(tbx_DenomName);
            Validation_Empty(tbx_DenomValue);
            Validation_Empty_ComboBox(Cmbx, Border_ItemGroupCmbx);
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

                    SqlCommand cmd = new SqlCommand("lkpDenominationsTypes", con);
                    cmd.CommandType = CommandType.StoredProcedure;

                    SqlDataAdapter sda = new SqlDataAdapter(cmd);
                    DataTable dt = new DataTable("DenomTypes");
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

        private void AddDenomination()
        {
            try
            {
                string ConString = ConfigurationManager.ConnectionStrings["ConString"].ConnectionString;
                using (SqlConnection con = new SqlConnection(ConString))
                {
                    con.Open();

                    SqlCommand cmd = new SqlCommand("stpDenomiations_Insert", con);

                    cmd.CommandType = CommandType.StoredProcedure;

                    cmd.Parameters.AddWithValue("@Name", tbx_DenomName.Text);
                    cmd.Parameters.AddWithValue("@Value", Decimal.Parse(tbx_DenomValue.Text));
                    cmd.Parameters.AddWithValue("@TypeId", Int32.Parse(Cmbx.SelectedValue.ToString()));
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
                TextBox.ToolTip = null;

                return true;
            }
        }

        private bool Validation_Empty_ComboBox(System.Windows.Controls.ComboBox cmbx, Border border)
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
                cmbx.ToolTip = null;

                return true;
            }
        }


        private void BtnCancel_Click(object sender, RoutedEventArgs e)
        {
            this.Close();
        }

        private void tbx_DenomName_KeyUp(object sender, KeyEventArgs e)
        {
            Validation_Empty(tbx_DenomName);
        }

        private void btnAddDenom_Click(object sender, RoutedEventArgs e)
        {
            if (!Validation_Empty(tbx_DenomName) || !Validation_Empty(tbx_DenomValue))
            {
                MessageBox.Show("Fields cannot be empty", "Error");
            }
            else
            {
                if (Cmbx.SelectedValue == null)
                {
                    MessageBox.Show("Please select a type.", "Error");
                }
                else
                {
                    AddDenomination();
                }
                
            }
        }

        private void tbx_DenomValue_KeyUp(object sender, KeyEventArgs e)
        {
            Validation_Empty(tbx_DenomValue);
        }

        private void Cmbx_DropDownClosed(object sender, EventArgs e)
        {
            Validation_Empty_ComboBox(Cmbx, Border_ItemGroupCmbx);
        }
    }
}
