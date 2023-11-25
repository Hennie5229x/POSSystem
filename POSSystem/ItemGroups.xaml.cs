using System;
using System.Collections.Generic;
using System.Configuration;
using System.Data;
using System.Data.SqlClient;
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

namespace POSSystem
{
    /// <summary>
    /// Interaction logic for ItemGroups.xaml
    /// </summary>
    public partial class ItemGroups : Window
    {
        public ItemGroups()
        {
            InitializeComponent();

            FillDataGrid();
        }

        private void FillDataGrid()
        {
            try
            {
                string ConString = ConfigurationManager.ConnectionStrings["ConString"].ConnectionString;
                using (SqlConnection con = new SqlConnection(ConString))
                {
                    SqlCommand cmd = new SqlCommand("stpItemGroups_Select", con);

                    cmd.CommandType = CommandType.StoredProcedure;                    

                    SqlDataAdapter sda = new SqlDataAdapter(cmd);
                    DataTable dt = new DataTable("ItemGroups");
                    sda.Fill(dt);
                    grdItemGroups.ItemsSource = dt.DefaultView;
                }
            }
            catch (Exception e)
            {
                MessageBox.Show(e.Message, "Error");
            }
        }       

        private void RemoveItemGroups(int Id)
        {
            try
            {
                string ConString = ConfigurationManager.ConnectionStrings["ConString"].ConnectionString;
                using (SqlConnection con = new SqlConnection(ConString))
                {
                    con.Open();

                    SqlCommand cmd = new SqlCommand("stpItemGroups_Delete", con);

                    cmd.CommandType = CommandType.StoredProcedure;

                    cmd.Parameters.AddWithValue("@Id", Id);                   
                    cmd.Parameters.AddWithValue("@UserId", UserId.User_Id);

                    cmd.ExecuteNonQuery();

                    con.Close();                    
                }

            }
            catch (Exception e)
            {
                MessageBox.Show(e.Message, "Error");
            }
        }
               

        private void Btn_AddItemGroup_Click(object sender, RoutedEventArgs e)
        {
            //Insert
            ItemGroups_Add itemGroups_Add = new ItemGroups_Add();
            itemGroups_Add.ShowDialog();
            FillDataGrid();
        }

        private void BtnCancel_Click(object sender, RoutedEventArgs e)
        {
            this.Close();
        }

        private void MenuItem_Click(object sender, RoutedEventArgs e)
        {           
            //Update
            DataRowView dataRow = (DataRowView)grdItemGroups.SelectedItem;

            if (dataRow != null)
            {                
                string cellValue = dataRow.Row.ItemArray[0].ToString();

                ItemGroups_Update itemGroups_Update = new ItemGroups_Update(Int32.Parse(cellValue));
                itemGroups_Update.ShowDialog();
                FillDataGrid();
            }

            
        }

        private void MenuItem_Click_1(object sender, RoutedEventArgs e)
        {
            //Delete
            MessageBoxResult messageBoxResult = System.Windows.MessageBox.Show("Are you sure you want to remove selected Group?", "Delete Confirmation", System.Windows.MessageBoxButton.YesNo);
            if (messageBoxResult == MessageBoxResult.Yes)
            {
                DataRowView dataRow = (DataRowView)grdItemGroups.SelectedItem;

                if (dataRow != null)
                {
                    string cellValue = dataRow.Row.ItemArray[0].ToString();

                    RemoveItemGroups(Int32.Parse(cellValue));
                    FillDataGrid();
                }


            }
        }
    }
}
