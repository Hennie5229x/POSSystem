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
using System.Windows.Navigation;
using System.Windows.Shapes;
using System.Configuration;
using System.Data;
using System.Data.SqlClient;
using System.IO;
using System.Diagnostics;
using POSSystem_Manager;

namespace POSSystem
{
    /// <summary>
    /// Interaction logic for MainWindow.xaml
    /// </summary>
    public partial class MainWindow : Window
    {
        public MainWindow()
        {
            InitializeComponent();
            //this.ResizeMode = ResizeMode.NoResize;
        }

        private string _UserId = null;

        private void Login()
        {
            try
            {

                string ConString = ConfigurationManager.ConnectionStrings["ConString"].ConnectionString;
                string CmdString = string.Empty;
                using (SqlConnection con = new SqlConnection(ConString))
                {
                    con.Open();

                    SqlCommand cmd = new SqlCommand("stpUsers_Login", con);
                    cmd.CommandType = CommandType.StoredProcedure;

                    cmd.Parameters.AddWithValue("@LoginName", tbx_LoginName.Text);
                    cmd.Parameters.AddWithValue("@Password", tbx_Password.Password);

                    SqlDataReader reader = cmd.ExecuteReader();

                    string Result = null;
                    string Id = null;

                    while (reader.Read())
                    {
                        Result = reader["Result"].ToString();
                        Id = reader["Id"].ToString();
                    }

                    //string LoggedIn = null;

                    if (Result == "1")
                    {

                        UserId.User_Id = Id;

                        HistoryLog(Id, "Login", "Successfully loggend in", "", "");

                        DashBoard dashBoard = new DashBoard();
                        dashBoard.Show();
                        this.Close();
                    }
                    else
                    {
                        //string message = Id;
                        //MessageBox.Show(message);

                        HistoryLog(Id, "Login", "Log in failed. Attempted: "+ tbx_LoginName.Text, "", "");
                        MessageBox.Show("Login failed, username and/or password is incorect", "Login Failed");
                    }

                    

                    con.Close();

                }
            }
            catch (Exception e)
            {
                MessageBox.Show(e.Message, "Error");
            }
        }

        private void HistoryLog(string UserId, string Action, string Description, string From, string To)
        {
            try
            {

                string ConString = ConfigurationManager.ConnectionStrings["ConString"].ConnectionString;
                string CmdString = string.Empty;
                using (SqlConnection con = new SqlConnection(ConString))
                {
                    con.Open();

                    SqlCommand cmd = new SqlCommand("stpHistoryLog_Insert", con);
                    cmd.CommandType = CommandType.StoredProcedure;

                    cmd.Parameters.AddWithValue("@UserId", UserId);
                    cmd.Parameters.AddWithValue("@Action", Action);
                    cmd.Parameters.AddWithValue("@Description", Description);
                    cmd.Parameters.AddWithValue("@FromValue", From);
                    cmd.Parameters.AddWithValue("@ToValue", To);
                    cmd.Parameters.AddWithValue("@FieldId", null);

                    cmd.ExecuteNonQuery();                                       
                    con.Close();

                }
            }
            catch (Exception e)
            {
                MessageBox.Show(e.Message, "Error");
            }
        }

        private Boolean ValidLoginName(string LoginName)
        {
            Boolean Result = false;
            
            try
            {
                string ConString = ConfigurationManager.ConnectionStrings["ConString"].ConnectionString;               
                using (SqlConnection con = new SqlConnection(ConString))
                {
                    con.Open();

                    SqlCommand cmd = new SqlCommand("stpResetPassword_ValidLoginName", con);
                    cmd.CommandType = CommandType.StoredProcedure;

                    cmd.Parameters.AddWithValue("@LoginName", LoginName);

                    SqlDataReader reader = cmd.ExecuteReader();

                    while (reader.Read())
                    {
                        Result = Boolean.Parse(reader["Result"].ToString());
                        _UserId = reader["UserId"].ToString();
                    }

                    con.Close();
                }
            }
            catch (Exception e)
            {
                MessageBox.Show(e.Message, "Error");
            }

            return Result;
        }

        private void MenuItem_Click(object sender, RoutedEventArgs e)
        {
            this.Close();
        }

        private void Btn_Login_Click(object sender, RoutedEventArgs e)
        {
            Login();
        }

        private void Tbx_Password_KeyDown(object sender, KeyEventArgs e)
        {
            if (e.Key == System.Windows.Input.Key.Enter)
            {
                Login();
            }
        }

        private void Btn_Reset_Click(object sender, RoutedEventArgs e)
        {
            if (!ValidLoginName(tbx_LoginName.Text))
            {
                MessageBox.Show("Please enter a valid login name", "Error");
            }
            else
            {
                ResetPassword resetPassword = new ResetPassword(_UserId, tbx_LoginName.Text);
                resetPassword.ShowDialog();
            }
        }

        private void MenuItem_Click_1(object sender, RoutedEventArgs e)
        {
            string startupPath = System.IO.Path.Combine(Directory.GetParent(System.IO.Directory.GetCurrentDirectory()).Parent.Parent.Parent.FullName);
            startupPath = startupPath + @"\POSSystem\POSSystem_Retail\bin\Debug\POSSystem_Retail.exe";

            Process.Start(startupPath);
        }

        private void MenuItem_Click_2(object sender, RoutedEventArgs e)
        {
            DatabaseConnection databaseConnection = new DatabaseConnection();
            databaseConnection.ShowDialog();

        }
    }
}
