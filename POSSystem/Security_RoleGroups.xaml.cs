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
using System.Windows.Controls.Primitives;

namespace POSSystem
{
    /// <summary>
    /// Interaction logic for Security_RoleGroups.xaml
    /// </summary>
    public partial class Security_RoleGroups : Window
    {
        public Security_RoleGroups()
        {
            InitializeComponent();
            FillDataGrid();
        }

        private void FillDataGrid()
        {
            string ConString = ConfigurationManager.ConnectionStrings["ConString"].ConnectionString;
            using (SqlConnection con = new SqlConnection(ConString))
            {
                SqlCommand cmd = new SqlCommand("stpRoleGroups_Select", con);
                cmd.CommandType = CommandType.StoredProcedure;                

                SqlDataAdapter sda = new SqlDataAdapter(cmd);
                DataTable dt = new DataTable("RoleGroups");
                sda.Fill(dt);
                grdRoleGroup.ItemsSource = dt.DefaultView;
            }
        }
               
        private void BtnCancel_Click(object sender, RoutedEventArgs e)
        {
            this.Close();
        }

        private void Btn_AddRoleGroup_Click(object sender, RoutedEventArgs e)
        {
            Security_RoleGroups_Add securityRGA = new Security_RoleGroups_Add();

            securityRGA.ShowDialog();
            this.FillDataGrid();
        }

        private void MenuItem_Click(object sender, RoutedEventArgs e)
        {
            //Update
            DataRowView dataRow = (DataRowView)grdRoleGroup.SelectedItem;

            if (dataRow != null)
            {
                int index = grdRoleGroup.CurrentCell.Column.DisplayIndex;
                string cellValue = dataRow.Row.ItemArray[0].ToString();

                Security_RoleGroups_Update SRGUpdate = new Security_RoleGroups_Update(cellValue);
                SRGUpdate.ShowDialog();
                FillDataGrid();
            }


        }
                 

        private void Button_Click(object sender, RoutedEventArgs e)
        {
            // Role Group Users
            DataRowView dataRow = (DataRowView)grdRoleGroup.SelectedItem;

            if (dataRow != null)
            {
                int index = grdRoleGroup.CurrentCell.Column.DisplayIndex;
                string cellValue = dataRow.Row.ItemArray[0].ToString();

                Security_RoleGroups_RoleGroupUsers Security_RGU = new Security_RoleGroups_RoleGroupUsers(cellValue);
                Security_RGU.ShowDialog();
                FillDataGrid();
            }
        }

        private void Button_Click_1(object sender, RoutedEventArgs e)
        {
            // Role Group Objects
            DataRowView dataRow = (DataRowView)grdRoleGroup.SelectedItem;

            if (dataRow != null)
            {
                int index = grdRoleGroup.CurrentCell.Column.DisplayIndex;
                string cellValue = dataRow.Row.ItemArray[0].ToString();

                Security_RoleGroups_RoleGroupObjects securityRGO = new Security_RoleGroups_RoleGroupObjects(cellValue);
                securityRGO.ShowDialog();
                FillDataGrid();
            }

        }
    }
}
