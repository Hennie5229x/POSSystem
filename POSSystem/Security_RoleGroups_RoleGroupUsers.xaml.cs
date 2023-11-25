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
    /// Interaction logic for Security_RoleGroups_RoleGroupUsers.xaml
    /// </summary>
    public partial class Security_RoleGroups_RoleGroupUsers : Window
    {
        public Security_RoleGroups_RoleGroupUsers(string RoleGroup_Id)
        {
            InitializeComponent();
            RoleGroupId = Int32.Parse(RoleGroup_Id);
            FillDataGrid();
        }

        int RoleGroupId;

        private void FillDataGrid()
        {
            try
            {
                string ConString = ConfigurationManager.ConnectionStrings["ConString"].ConnectionString;
                using (SqlConnection con = new SqlConnection(ConString))
                {
                    SqlCommand cmd = new SqlCommand("stpRoleGroupsUsers_Select", con);

                    cmd.CommandType = CommandType.StoredProcedure;
                    cmd.Parameters.AddWithValue("@RoleGroupId", RoleGroupId);

                    SqlDataAdapter sda = new SqlDataAdapter(cmd);
                    DataTable dt = new DataTable("RoleGroupUsers");
                    sda.Fill(dt);
                    grdRoleGroupUsers.ItemsSource = dt.DefaultView;
                }
            }catch(Exception e)
            {
                MessageBox.Show(e.Message, "Error");
            }
        }

        private void RemoveRoleGroupUser(int RoleGroup_Id, string User_Id)
        {
            try
            {
                string ConString = ConfigurationManager.ConnectionStrings["ConString"].ConnectionString;
                using (SqlConnection con = new SqlConnection(ConString))
                {
                    con.Open();

                    SqlCommand cmd = new SqlCommand("stpRoleGroupsUsers_Delete", con);

                    cmd.CommandType = CommandType.StoredProcedure;

                    cmd.Parameters.AddWithValue("@RoleGroupId", RoleGroup_Id);
                    cmd.Parameters.AddWithValue("@UserId", User_Id);
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

        private void Btn_AddRoleGroupUser_Click(object sender, RoutedEventArgs e)
        {
            //Add

            Security_RoleGroups_RoleGroupUsers_Add securityRoleGroupUsersAdd = new Security_RoleGroups_RoleGroupUsers_Add(RoleGroupId.ToString());

            securityRoleGroupUsersAdd.ShowDialog();
            FillDataGrid();

        }
               

        private void MenuItem_Click_1(object sender, RoutedEventArgs e)
        {
            //Delete
            MessageBoxResult messageBoxResult = System.Windows.MessageBox.Show("Are you sure you want to remove selected user?", "Delete Confirmation", System.Windows.MessageBoxButton.YesNo);
            if (messageBoxResult == MessageBoxResult.Yes)
            {
                DataRowView dataRow = (DataRowView)grdRoleGroupUsers.SelectedItem;

                if (dataRow != null)
                {
                    int index = grdRoleGroupUsers.CurrentCell.Column.DisplayIndex;
                    string cellValue = dataRow.Row.ItemArray[0].ToString();
                    
                    RemoveRoleGroupUser(RoleGroupId, cellValue);
                    FillDataGrid();
                }

                
            }            

        }

        private void BtnCancel_Click(object sender, RoutedEventArgs e)
        {
            //Close
            this.Close();
        }
    }
}
