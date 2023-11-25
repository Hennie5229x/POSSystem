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
    /// Interaction logic for UserManagement_AddUser.xaml
    /// </summary>
    public partial class UserManagement_AddUser : Window
    {
        public UserManagement_AddUser()
        {
            InitializeComponent();
            this.ResizeMode = ResizeMode.NoResize;

            //Validations:
            Validation_Empty(tbx_LoginName);
            Validation_Empty(tbx_Name);
            Validation_Empty(tbx_Surname);
            Validation_Empty(tbx_Pin);
            ValidationPassword_Empty(tbx_Password);
            ValidationPassword_Empty(tbx_ConfirmPassword);
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

        private void AddUser()
        {
            try
            {

                string ConString = ConfigurationManager.ConnectionStrings["ConString"].ConnectionString;
                using (SqlConnection con = new SqlConnection(ConString))
                {
                    con.Open();

                    SqlCommand cmd = new SqlCommand("stpUsers_Insert", con);

                    cmd.CommandType = CommandType.StoredProcedure;

                    cmd.Parameters.AddWithValue("@LoginName", tbx_LoginName.Text);
                    cmd.Parameters.AddWithValue("@Password", tbx_Password.Password);
                    cmd.Parameters.AddWithValue("@Name", tbx_Name.Text);
                    cmd.Parameters.AddWithValue("@Surname", tbx_Surname.Text);
                    cmd.Parameters.AddWithValue("@Phone", tbx_Phone.Text);
                    cmd.Parameters.AddWithValue("@Email", tbx_Email.Text);
                    cmd.Parameters.AddWithValue("@UserId", UserId.User_Id);
                    cmd.Parameters.AddWithValue("@Pin", tbx_Pin.Text);

                    cmd.ExecuteNonQuery();

                    con.Close();
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

        //Inputs Key Up events for validations////
        ////////////////////////////////////////
        private void Tbx_LoginName_KeyUp(object sender, KeyEventArgs e)
        {
            Validation_Empty(tbx_LoginName);
        }
        private void Tbx_Password_KeyUp(object sender, KeyEventArgs e)
        {
            ValidationPassword_Empty(tbx_Password);
        }
        private void Tbx_ConfirmPassword_KeyUp(object sender, KeyEventArgs e)
        {            
            ValidationPassword_Empty(tbx_ConfirmPassword);            
        }
        private void Tbx_Name_KeyUp(object sender, KeyEventArgs e)
        {
            Validation_Empty(tbx_Name);
        }
        private void Tbx_Surname_KeyUp(object sender, KeyEventArgs e)
        {
            Validation_Empty(tbx_Surname);
        }
        private void Tbx_Pin_KeyUp(object sender, KeyEventArgs e)
        {
            Validation_Empty(tbx_Pin);
        }
        ////////////////////////////////////////


        private void BtnAddUser_Click(object sender, RoutedEventArgs e)
        {
            if (tbx_Password.Password != tbx_ConfirmPassword.Password)
            {
                MessageBox.Show("The Passwords do not match.", "Password mismatch.");
            }
            else if (!Validation_Empty(tbx_LoginName) || !ValidationPassword_Empty(tbx_Password) || !ValidationPassword_Empty(tbx_ConfirmPassword) || !Validation_Empty(tbx_Name) || !Validation_Empty(tbx_Surname) 
                    || !Validation_Empty(tbx_Pin))
            {
                MessageBox.Show("Required fields cannot be empty.", "Required Fields Empty");
            }
            else
            {
                AddUser();
                this.Close();
            }
        }

        
    }
}
