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
    /// Interaction logic for ResetPassword.xaml
    /// </summary>
    public partial class ResetPassword : Window
    {
        public ResetPassword(string _UserId, string _LoginName)
        {
            InitializeComponent();

            tbx_LoginName.Text = _LoginName;
            UserId = _UserId;

            //Validations
            ValidationPassword_Empty(tbx_CurrentPassword);
            ValidationPassword_Empty(tbx_Password);
            ValidationPassword_Empty(tbx_ConfirmPassword);

        }

        string UserId;

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

        private void ResetPass()
        {
            try
            {
                string ConString = ConfigurationManager.ConnectionStrings["ConString"].ConnectionString;
                using (SqlConnection con = new SqlConnection(ConString))
                {
                    con.Open();

                    SqlCommand cmd = new SqlCommand("stpResetPassword", con);

                    cmd.CommandType = CommandType.StoredProcedure;
                    
                    cmd.Parameters.AddWithValue("@UserId", UserId);
                    cmd.Parameters.AddWithValue("@CurrentPass", tbx_CurrentPassword.Password);
                    cmd.Parameters.AddWithValue("@NewPass", tbx_Password.Password);
                    cmd.Parameters.AddWithValue("@ConfirmPass", tbx_ConfirmPassword.Password);

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

        private void BtnCancel_Click(object sender, RoutedEventArgs e)
        {
            this.Close();
        }

        private void BtnResetPass_Click(object sender, RoutedEventArgs e)
        {
            if (!ValidationPassword_Empty(tbx_CurrentPassword) || !ValidationPassword_Empty(tbx_Password) || !ValidationPassword_Empty(tbx_ConfirmPassword))
            {
                MessageBox.Show("All password field are required", "Error");
            }
            else
            {
                MessageBoxResult messageBoxResult = System.Windows.MessageBox.Show("Are you sure you want to reset password?", "Reset Confirmation", System.Windows.MessageBoxButton.YesNo);
                if (messageBoxResult == MessageBoxResult.Yes)
                {
                    ResetPass();
                }
            }
            
        }

        private void Tbx_CurrentPassword_KeyUp(object sender, KeyEventArgs e)
        {
            ValidationPassword_Empty(tbx_CurrentPassword);
            ValidationPassword_Empty(tbx_Password);
            ValidationPassword_Empty(tbx_ConfirmPassword);
        }

        private void Tbx_Password_KeyUp(object sender, KeyEventArgs e)
        {
            ValidationPassword_Empty(tbx_CurrentPassword);
            ValidationPassword_Empty(tbx_Password);
            ValidationPassword_Empty(tbx_ConfirmPassword);
        }

        private void Tbx_ConfirmPassword_KeyUp(object sender, KeyEventArgs e)
        {
            ValidationPassword_Empty(tbx_CurrentPassword);
            ValidationPassword_Empty(tbx_Password);
            ValidationPassword_Empty(tbx_ConfirmPassword);
        }
    }
}
