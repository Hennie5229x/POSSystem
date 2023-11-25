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
   
    public partial class ItemGroups_Add : Window
    {
        public ItemGroups_Add()
        {
            InitializeComponent();

            Validation_Empty(tbx_Name);
        }

        private void AddItemGroups()
        {
            try
            {
                string ConString = ConfigurationManager.ConnectionStrings["ConString"].ConnectionString;
                using (SqlConnection con = new SqlConnection(ConString))
                {
                    con.Open();

                    SqlCommand cmd = new SqlCommand("stpItemGroups_Insert", con);

                    cmd.CommandType = CommandType.StoredProcedure;

                    cmd.Parameters.AddWithValue("@GroupName", tbx_Name.Text);
                    cmd.Parameters.AddWithValue("@Description", tbx_Description.Text);
                    cmd.Parameters.AddWithValue("@UserId", UserId.User_Id);

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

        private void BtnAddGroup_Click(object sender, RoutedEventArgs e)
        {
            if (!Validation_Empty(tbx_Name))
            {
                MessageBox.Show("Group Name cannot be empty", "Error");
            }
            else
            {
                AddItemGroups();
            }            
        }

        private void Tbx_Name_KeyUp(object sender, KeyEventArgs e)
        {
            Validation_Empty(tbx_Name);
        }
    }
}
