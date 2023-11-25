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
    /// Interaction logic for Security_RoleGroups_Add.xaml
    /// </summary>
    public partial class Security_RoleGroups_Add : Window
    {
        public Security_RoleGroups_Add()
        {
            InitializeComponent();
            Validation_Empty(tbx_RoleGroupName);
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

        private void AddRoleGroup()
        {
            try
            {

                string ConString = ConfigurationManager.ConnectionStrings["ConString"].ConnectionString;
                using (SqlConnection con = new SqlConnection(ConString))
                {
                    con.Open();

                    SqlCommand cmd = new SqlCommand("stpRoleGroup_Insert", con);

                    cmd.CommandType = CommandType.StoredProcedure;

                    cmd.Parameters.AddWithValue("@RoleGroupName", tbx_RoleGroupName.Text);
                    cmd.Parameters.AddWithValue("@RoleGroupDescription", tbx_RoleGroupDescription.Text);                    
                    cmd.Parameters.AddWithValue("@UserId", UserId.User_Id);

                    cmd.ExecuteNonQuery();

                    con.Close();
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

        private void Tbx_RoleGroupName_KeyUp(object sender, KeyEventArgs e)
        {
            Validation_Empty(tbx_RoleGroupName);
        }

        private void BtnAddRoleGroup_Click(object sender, RoutedEventArgs e)
        {
            if(Validation_Empty(tbx_RoleGroupName))
            {
                AddRoleGroup();
                this.Close();
            }
            else
            {
                MessageBox.Show("Required fields cannot be empty.", "Required Fields Empty");
            }
        }
    }
}
