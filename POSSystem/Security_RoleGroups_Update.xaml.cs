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
    /// Interaction logic for Security_RoleGroups_Update.xaml
    /// </summary>
    public partial class Security_RoleGroups_Update : Window
    {
        public Security_RoleGroups_Update(string RoleGroup_Id)
        {
            InitializeComponent();
            RoleGroupId = Int32.Parse(RoleGroup_Id);
            GetValues();
        }

        int RoleGroupId;

        private void UpdateRollGroup()
        {
            try
            {
                string ConString = ConfigurationManager.ConnectionStrings["ConString"].ConnectionString;
                using (SqlConnection con = new SqlConnection(ConString))
                {
                    con.Open();

                    SqlCommand cmd = new SqlCommand("stpRoleGroup_Update", con);

                    cmd.CommandType = CommandType.StoredProcedure;

                    cmd.Parameters.AddWithValue("@Id", RoleGroupId);
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

        private void GetValues()
        {
            try
            {
                string ConString = ConfigurationManager.ConnectionStrings["ConString"].ConnectionString;
                using (SqlConnection con = new SqlConnection(ConString))
                {
                    con.Open();

                    SqlCommand cmd = new SqlCommand("stpRoleGroups_Values_Select", con);
                    cmd.CommandType = CommandType.StoredProcedure;

                    cmd.Parameters.AddWithValue("@Id", RoleGroupId);

                    SqlDataReader reader = cmd.ExecuteReader();

                    string Name = null;                    
                    string Description = null;

                    while (reader.Read())
                    {
                        Name = reader["Name"].ToString();
                        Description = reader["Description"].ToString();                       
                    }

                    tbx_RoleGroupName.Text = Name;
                    tbx_RoleGroupDescription.Text = Description;

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

        private void BtnUpdateRoleGroup_Click(object sender, RoutedEventArgs e)
        {
            UpdateRollGroup();
            this.Close();
        }
    }
}
