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
    /// Interaction logic for Security_RoleGroups_RoleGroupObjects_Add.xaml
    /// </summary>
    public partial class Security_RoleGroups_RoleGroupObjects_Add : Window
    {
        public Security_RoleGroups_RoleGroupObjects_Add(string RoleGroup_Id)
        {
            InitializeComponent();
            RoleGroupId = Int32.Parse(RoleGroup_Id);
            tbx_RoleGroupName.Text = GetRoleGroupName(RoleGroup_Id);
            FillLookup();
        }

        int RoleGroupId;

        private void AddRoleGroupObject()
        {
            try
            {
                string ConString = ConfigurationManager.ConnectionStrings["ConString"].ConnectionString;
                using (SqlConnection con = new SqlConnection(ConString))
                {
                    con.Open();

                    SqlCommand cmd = new SqlCommand("stpRoleGroupsObjects_Insert", con);

                    cmd.CommandType = CommandType.StoredProcedure;

                    cmd.Parameters.AddWithValue("@RoleGroupId", RoleGroupId);
                    cmd.Parameters.AddWithValue("@ObjectId", Cmbx.SelectedValue.ToString());
                    cmd.Parameters.AddWithValue("@LoggedInUserId", UserId.User_Id);

                    cmd.ExecuteNonQuery();

                    con.Close();
                }

            }
            catch (Exception e)
            {
                MessageBox.Show(e.Message, "Error");
            }
        }

        private void FillLookup()
        {
            try
            {
                string ConString = ConfigurationManager.ConnectionStrings["ConString"].ConnectionString;
                //string CmdString = string.Empty;
                using (SqlConnection con = new SqlConnection(ConString))
                {
                    con.Open();

                    SqlCommand cmd = new SqlCommand("lkpObjects", con);
                    cmd.CommandType = CommandType.StoredProcedure;

                    //SqlDataReader reader = cmd.ExecuteReader();

                    SqlDataAdapter sda = new SqlDataAdapter(cmd);
                    DataTable dt = new DataTable("RoleGroupObjects");
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

        private string GetRoleGroupName(string RoleGroup_Id)
        {
            string RoleGroupName = null;
            try
            {
                string ConString = ConfigurationManager.ConnectionStrings["ConString"].ConnectionString;
                //string CmdString = string.Empty;
                using (SqlConnection con = new SqlConnection(ConString))
                {
                    con.Open();

                    SqlCommand cmd = new SqlCommand("calcRoleGroupUsersName", con);
                    cmd.CommandType = CommandType.StoredProcedure;

                    cmd.Parameters.AddWithValue("@RoleGroupId", RoleGroup_Id);

                    SqlDataReader reader = cmd.ExecuteReader();

                    while (reader.Read())
                    {
                        RoleGroupName = reader["Name"].ToString();
                    }

                    con.Close();
                }
            }
            catch (Exception e)
            {
                MessageBox.Show(e.Message, "Error");
            }

            return RoleGroupName;
        }

        private void BtnCancel_Click(object sender, RoutedEventArgs e)
        {
            this.Close();
        }

        private void BtnAddObject_Click(object sender, RoutedEventArgs e)
        {
            if (Cmbx.SelectedValue == null)
            {
                MessageBox.Show("Object cannot be empty", "Error");
            }
            else
            {
                AddRoleGroupObject();
                this.Close();
            }
        }
    }
}
