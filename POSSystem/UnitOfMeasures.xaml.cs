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
    /// Interaction logic for UnitOfMeasures.xaml
    /// </summary>
    public partial class UnitOfMeasures : Window
    {
        public UnitOfMeasures()
        {
            InitializeComponent();
            FillDataGrid();
        }

        private void btn_AddUoM_Click(object sender, RoutedEventArgs e)
        {
            //Add UoM
            UnitOfMeasures_Add unitOfMeasures_Add = new UnitOfMeasures_Add();
            unitOfMeasures_Add.ShowDialog();
            FillDataGrid();
        }

        private void FillDataGrid()
        {
            try
            {
                string ConString = ConfigurationManager.ConnectionStrings["ConString"].ConnectionString;
                using (SqlConnection con = new SqlConnection(ConString))
                {
                    SqlCommand cmd = new SqlCommand("stpUOM_Select", con);

                    cmd.CommandType = CommandType.StoredProcedure;

                    SqlDataAdapter sda = new SqlDataAdapter(cmd);
                    DataTable dt = new DataTable("UoM");
                    sda.Fill(dt);
                    grdUoM.ItemsSource = dt.DefaultView;
                }
            }
            catch (Exception e)
            {
                MessageBox.Show(e.Message, "Error");
            }
        }

        private void MenuItem_Click(object sender, RoutedEventArgs e)
        {
            //Update
            DataRowView dataRow = (DataRowView)grdUoM.SelectedItem;

            if (dataRow != null)
            {
                string cellValue = dataRow.Row.ItemArray[0].ToString();

                UnitOfMeasures_Update UoM_Update = new UnitOfMeasures_Update(Int32.Parse(cellValue));
                UoM_Update.ShowDialog();
                this.FillDataGrid();
            }
        }
    }
}
