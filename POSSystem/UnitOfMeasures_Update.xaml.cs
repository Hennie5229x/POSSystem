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
using POSSystem;

namespace POSSystem_Manager
{
    /// <summary>
    /// Interaction logic for Printers_Update.xaml
    /// </summary>
    public partial class UnitOfMeasures_Update : Window
    {
        public UnitOfMeasures_Update(int _id)
        {
            InitializeComponent();
            
            Id = _id;
            ItemGroupValues();
        }

        int Id;

        private void ItemGroupValues()
        {
            string Name = null;
            string Description = null;

            try
            {
                string ConString = ConfigurationManager.ConnectionStrings["ConString"].ConnectionString;
                //string CmdString = string.Empty;
                using (SqlConnection con = new SqlConnection(ConString))
                {
                    con.Open();

                    SqlCommand cmd = new SqlCommand("calcUoM_Values", con);
                    cmd.CommandType = CommandType.StoredProcedure;

                    cmd.Parameters.AddWithValue("@Id", Id);

                    SqlDataReader reader = cmd.ExecuteReader();

                    while (reader.Read())
                    {
                        Name = reader["UoM"].ToString();
                        Description = reader["Description"].ToString();
                    }

                    con.Close();

                    tbx_PrinterName.Text = Name;
                    tbx_Description.Text = Description;

                }
            }
            catch (Exception e)
            {
                MessageBox.Show(e.Message, "Error");
            }


        }

        private void UpdateUoM()
        {
            try
            {
                string ConString = ConfigurationManager.ConnectionStrings["ConString"].ConnectionString;
                using (SqlConnection con = new SqlConnection(ConString))
                {
                    con.Open();

                    SqlCommand cmd = new SqlCommand("stpUoM_Update", con);

                    cmd.CommandType = CommandType.StoredProcedure;

                    cmd.Parameters.AddWithValue("@Id", Id);
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
               

        private void BtnCancel_Click(object sender, RoutedEventArgs e)
        {
            this.Close();
        }

        private void btnUpdateUoM_Click(object sender, RoutedEventArgs e)
        {
            UpdateUoM();
        }
    }
}
