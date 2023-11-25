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
    /// Interaction logic for UserManagement.xaml
    /// </summary>
    public partial class UserManagement : Window
    {
        public UserManagement()
        {
            InitializeComponent();
            //this.ResizeMode = ResizeMode.NoResize;
            FillDataGrid();
        }

        public void FillDataGrid()
        {
            string ConString = ConfigurationManager.ConnectionStrings["ConString"].ConnectionString;           
            using (SqlConnection con = new SqlConnection(ConString))
            {
                SqlCommand cmd = new SqlCommand("stpUsers_Select", con);
                cmd.CommandType = CommandType.StoredProcedure;
                cmd.Parameters.AddWithValue("@LoginName", tbx_LoginName.Text);
                cmd.Parameters.AddWithValue("@Name", tbx_Name.Text);
                cmd.Parameters.AddWithValue("@Surname", tbx_Surname.Text);  

                SqlDataAdapter sda = new SqlDataAdapter(cmd);
                DataTable dt = new DataTable("Users");
                sda.Fill(dt);
                grdUsers.ItemsSource = dt.DefaultView;
            }
        }

        private void MenuItem_Update_Click(object sender, RoutedEventArgs e)
        {
            DataRowView dataRow = (DataRowView)grdUsers.SelectedItem;

            if (dataRow != null)
            {
                int index = grdUsers.CurrentCell.Column.DisplayIndex;
                string cellValue = dataRow.Row.ItemArray[0].ToString();

                UserManagement_UpdateUser umus = new UserManagement_UpdateUser(cellValue);
                umus.ShowDialog();
                FillDataGrid();
            }
        }

        private void Tbx_LoginName_KeyUp(object sender, KeyEventArgs e)
        {
            FillDataGrid();
        }
        
        private void Tbx_Name_KeyUp(object sender, KeyEventArgs e)
        {
            FillDataGrid();
        }

        private void Tbx_Surname_KeyUp(object sender, KeyEventArgs e)
        {
            FillDataGrid();
        }

        private void Btn_AddUser_Click(object sender, RoutedEventArgs e)
        {
            UserManagement_AddUser AddUser = new UserManagement_AddUser();           
            AddUser.ShowDialog();          
            FillDataGrid();
        }

        private void BtnCancel_Click(object sender, RoutedEventArgs e)
        {
            this.Close();
        }

        private void MenuItem_ActieInactive_Click(object sender, RoutedEventArgs e)
        {
            DataRowView dataRow = (DataRowView)grdUsers.SelectedItem;

            if (dataRow != null)
            {
                int index = grdUsers.CurrentCell.Column.DisplayIndex;
                string cellValue = dataRow.Row.ItemArray[0].ToString();

                UserManagement_ActiveInactive umai = new UserManagement_ActiveInactive(cellValue);
                umai.ShowDialog();
                FillDataGrid();
            }

            
        }

        private void MenuItem_Click(object sender, RoutedEventArgs e)
        {
            // Password Reset
            DataRowView dataRow = (DataRowView)grdUsers.SelectedItem;

            if (dataRow != null)
            {
                int index = grdUsers.CurrentCell.Column.DisplayIndex;
                string cellValue = dataRow.Row.ItemArray[0].ToString();

                UserManagement_PasswordReset USRP = new UserManagement_PasswordReset(cellValue);
                USRP.ShowDialog();
                FillDataGrid();
            }
        }
    }
}
