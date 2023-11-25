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
    /// Interaction logic for UserManagement_PasswordReset.xaml
    /// </summary>
    public partial class UserManagement_PasswordReset : Window
    {
        public UserManagement_PasswordReset(string SelectedUserId)
        {
            InitializeComponent();
            User_Id = SelectedUserId;
            GetUserValues();

            ValidationPassword_Empty(tbx_Password);
            ValidationPassword_Empty(tbx_ConfirmPassword);
        }
        string User_Id;

        private bool ValidationPassword_Empty(PasswordBox TextBox)
        {
            if (TextBox.Password == "" || TextBox.Password == null)
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

        private void ResetPassword()
        {
            try
            {

                string ConString = ConfigurationManager.ConnectionStrings["ConString"].ConnectionString;
                using (SqlConnection con = new SqlConnection(ConString))
                {
                    con.Open();

                    SqlCommand cmd = new SqlCommand("stpUsers_ResetPassword", con);

                    cmd.CommandType = CommandType.StoredProcedure;

                    cmd.Parameters.AddWithValue("@UserId", User_Id);
                    cmd.Parameters.AddWithValue("@LoggendInUserId", UserId.User_Id);                    
                    cmd.Parameters.AddWithValue("@Password", tbx_Password.Password);
                    cmd.Parameters.AddWithValue("@PasswordConfirm", tbx_ConfirmPassword.Password);                   

                    cmd.ExecuteNonQuery();

                    con.Close();
                }

                this.Close();

            }
            catch (Exception e)
            {
                MessageBox.Show(e.Message, "Error");
            }
        }

        private void GetUserValues()
        {
            try
            {
                string ConString = ConfigurationManager.ConnectionStrings["ConString"].ConnectionString;
                using (SqlConnection con = new SqlConnection(ConString))
                {
                    con.Open();

                    SqlCommand cmd = new SqlCommand("stpUsers_Values_Select", con);
                    cmd.CommandType = CommandType.StoredProcedure;

                    cmd.Parameters.AddWithValue("@Id", User_Id);

                    SqlDataReader reader = cmd.ExecuteReader();

                    string LoginName = null;                   

                    while (reader.Read())
                    {
                        LoginName = reader["LoginName"].ToString();                        
                    }

                    tbx_LoginName.Text = LoginName;                   

                    con.Close();

                }
            }
            catch (Exception e)
            {
                MessageBox.Show(e.Message, "Error");
            }
        }

        private void Tbx_Password_KeyUp(object sender, KeyEventArgs e)
        {
            ValidationPassword_Empty(tbx_Password);
        }

        private void Tbx_ConfirmPassword_KeyUp(object sender, KeyEventArgs e)
        {
            ValidationPassword_Empty(tbx_ConfirmPassword);
        }

        private void BtnCancel_Click(object sender, RoutedEventArgs e)
        {
            this.Close();
        }

        private void BtnResetPassword_Click(object sender, RoutedEventArgs e)
        {
            if (!ValidationPassword_Empty(tbx_Password) || !ValidationPassword_Empty(tbx_ConfirmPassword))
            {
                MessageBox.Show("Password fields cannot be empty", "Error");
            }
            else
            {
                ResetPassword();                
            }
        }
    }
}
