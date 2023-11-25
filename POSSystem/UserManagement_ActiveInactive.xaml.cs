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
    /// Interaction logic for UserManagement_ActiveInactive.xaml
    /// </summary>
    public partial class UserManagement_ActiveInactive : Window
    {
        public UserManagement_ActiveInactive(string _UserId)
        {
            InitializeComponent();
            User_Id = _UserId;

            GetUserValues();
        }

        string User_Id = null;

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
                    string ActiveStr = null;
                    bool Active;

                    while (reader.Read())
                    {
                        LoginName = reader["LoginName"].ToString();
                        ActiveStr = reader["Active"].ToString();
                    }

                    //MessageBox.Show(ActiveStr);                    

                    Active = bool.Parse(ActiveStr);


                    tbx_LoginName.Text = LoginName;
                    cbx_Active.IsChecked = Active;

                    con.Close();

                }

            }
            catch (Exception e)
            {
                MessageBox.Show(e.Message, "Error");
            }
        }

        private void ActiveInactive()
        {
           
                try
                {
                    string ConString = ConfigurationManager.ConnectionStrings["ConString"].ConnectionString;
                    using (SqlConnection con = new SqlConnection(ConString))
                    {
                        con.Open();

                        SqlCommand cmd = new SqlCommand("stpUsers_ActiveInactive", con);

                        cmd.CommandType = CommandType.StoredProcedure;

                        bool CheckboxState = cbx_Active.IsChecked.Value;
                        
                        cmd.Parameters.AddWithValue("@UserId", User_Id);
                        cmd.Parameters.AddWithValue("@Active", CheckboxState);
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

        private void BtnCancel_Click(object sender, RoutedEventArgs e)
        {
            this.Close();
        }

        private void BtnActiveInactive_Click(object sender, RoutedEventArgs e)
        {
            ActiveInactive();
            this.Close();
        }
    }
}
