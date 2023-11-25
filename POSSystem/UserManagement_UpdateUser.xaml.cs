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
    /// Interaction logic for UserManagement_UpdateUser.xaml
    /// </summary>
    public partial class UserManagement_UpdateUser : Window
    {
        public UserManagement_UpdateUser(string User_Id)
        {
            InitializeComponent();

            _UserId = User_Id;
            GetUserValues();

            //Validations
            Validation_Empty(tbx_Name);
            Validation_Empty(tbx_Surname);
            Validation_Empty(tbx_Pin);
        }

        private string _UserId = null;

        private void UpdateUser()
        {
            try
            {
                string ConString = ConfigurationManager.ConnectionStrings["ConString"].ConnectionString;
                using (SqlConnection con = new SqlConnection(ConString))
                {
                    con.Open();

                    SqlCommand cmd = new SqlCommand("stpUsers_Update", con);

                    cmd.CommandType = CommandType.StoredProcedure;

                    cmd.Parameters.AddWithValue("@UserId", _UserId);                   
                    cmd.Parameters.AddWithValue("@Name", tbx_Name.Text);
                    cmd.Parameters.AddWithValue("@Surname", tbx_Surname.Text);
                    cmd.Parameters.AddWithValue("@Phone", tbx_Phone.Text);
                    cmd.Parameters.AddWithValue("@Email", tbx_Email.Text);
                    cmd.Parameters.AddWithValue("@LoggedInUserId", UserId.User_Id);
                    cmd.Parameters.AddWithValue("@Pin", tbx_Pin.Text);

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

                    cmd.Parameters.AddWithValue("@Id", _UserId);

                    SqlDataReader reader = cmd.ExecuteReader();

                    string LoginName = null;
                    string Name = null;
                    string Surname = null;
                    string Phone = null;
                    string Email = null;
                    string Pin = null;

                    while (reader.Read())
                    {
                        LoginName = reader["LoginName"].ToString();
                        Name = reader["Name"].ToString();
                        Surname = reader["Surname"].ToString();
                        Phone = reader["Phone"].ToString();
                        Email = reader["Email"].ToString();
                        Pin = reader["Pin"].ToString();
                    }

                    tbx_LoginName.Text = LoginName;
                    tbx_Name.Text = Name;
                    tbx_Surname.Text = Surname;
                    tbx_Phone.Text = Phone;
                    tbx_Email.Text = Email;
                    tbx_Pin.Text = Pin;

                    con.Close();

                }
            }catch(Exception e)
            {
                MessageBox.Show(e.Message, "Error");
            }
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

        private void BtnCancel_Click(object sender, RoutedEventArgs e)
        {
            this.Close();
        }

        private void BtnUpdateUser_Click(object sender, RoutedEventArgs e)
        {
            if (!Validation_Empty(tbx_Pin) || !Validation_Empty(tbx_Name) || !Validation_Empty(tbx_Surname))
            {
                MessageBox.Show("Please fill in required fields", "Error");
            }
            else
            {
                UpdateUser();
            }
            
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
    }
}
