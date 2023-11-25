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

namespace POSSystem_Manager
{
    /// <summary>
    /// Interaction logic for Terminals.xaml
    /// </summary>
    public partial class Terminals : Window
    {
        public Terminals()
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
                    SqlCommand cmd = new SqlCommand("stpTerminals_Select", con);

                    cmd.CommandType = CommandType.StoredProcedure;

                    SqlDataAdapter sda = new SqlDataAdapter(cmd);
                    DataTable dt = new DataTable("Terminals");
                    sda.Fill(dt);
                    grdTerminals.ItemsSource = dt.DefaultView;
                }
            }
            catch (Exception e)
            {
                MessageBox.Show(e.Message, "Error");
            }
        }       


        private void Btn_AddTerminal_Click(object sender, RoutedEventArgs e)
        {
            //Add
            Terminals_Add terminals_Add = new Terminals_Add();
            terminals_Add.ShowDialog();
            FillDataGrid();

        }

        private void MenuItem_Click(object sender, RoutedEventArgs e)
        {
            //Update
            DataRowView dataRow = (DataRowView)grdTerminals.SelectedItem;

            if (dataRow != null)
            {
                string cellValue = dataRow.Row.ItemArray[0].ToString();

                Terminals_Update terminals_Update = new Terminals_Update(Int32.Parse(cellValue));
                terminals_Update.ShowDialog();
                this.FillDataGrid();
            }
        }
        
    }
}
