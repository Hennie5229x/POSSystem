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
    /// Interaction logic for Security_RoleGroups_RoleGroupObjects.xaml
    /// </summary>
    public partial class Security_RoleGroups_RoleGroupObjects : Window
    {
        public Security_RoleGroups_RoleGroupObjects(string RoleGroup_Id)
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
                    SqlCommand cmd = new SqlCommand("stpRoleGroupsObjects_Select", con);

                    cmd.CommandType = CommandType.StoredProcedure;
                    cmd.Parameters.AddWithValue("@RoleGroupId", RoleGroupId);

                    SqlDataAdapter sda = new SqlDataAdapter(cmd);
                    DataTable dt = new DataTable("RoleGroupObjects");
                    sda.Fill(dt);
                    grdRoleGroupObjects.ItemsSource = dt.DefaultView;
                }
            }
            catch (Exception e)
            {
                MessageBox.Show(e.Message, "Error");
            }
        }

        private void RemoveRoleGroupObjects(int RoleGroup_Id, string Object_Id)
        {
            try
            {
                string ConString = ConfigurationManager.ConnectionStrings["ConString"].ConnectionString;
                using (SqlConnection con = new SqlConnection(ConString))
                {
                    con.Open();

                    SqlCommand cmd = new SqlCommand("stpRoleGroupsObjects_Delete", con);

                    cmd.CommandType = CommandType.StoredProcedure;

                    cmd.Parameters.AddWithValue("@RoleGroupId", RoleGroup_Id);
                    cmd.Parameters.AddWithValue("@ObjectId", Object_Id);
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

        private void Btn_AddRoleGroupObject_Click(object sender, RoutedEventArgs e)
        {
            Security_RoleGroups_RoleGroupObjects_Add security_RGOA = new Security_RoleGroups_RoleGroupObjects_Add(RoleGroupId.ToString());
            security_RGOA.ShowDialog();
            FillDataGrid();
        }

        private void BtnCancel_Click(object sender, RoutedEventArgs e)
        {
            this.Close();
        }       
        
        private void MenuItem_Click_1(object sender, RoutedEventArgs e)
        {
            //Delete
            MessageBoxResult messageBoxResult = System.Windows.MessageBox.Show("Are you sure you want to remove selected object?", "Delete Confirmation", System.Windows.MessageBoxButton.YesNo);
            if (messageBoxResult == MessageBoxResult.Yes)
            {
                DataRowView dataRow = (DataRowView)grdRoleGroupObjects.SelectedItem;

                if (dataRow != null)
                {
                    int index = grdRoleGroupObjects.CurrentCell.Column.DisplayIndex;
                    string cellValue = dataRow.Row.ItemArray[0].ToString();

                    RemoveRoleGroupObjects(RoleGroupId, cellValue);
                    FillDataGrid();
                }

            }
        }
    }
}
