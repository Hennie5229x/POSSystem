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

namespace POSSystem_Retail
{
    /// <summary>
    /// Interaction logic for ItemSearch.xaml
    /// </summary>
    public partial class ItemSearch : Window
    {
        public ItemSearch(string _Type = "SALE", string _ReturnType = "", bool _RtnAllLines = false, string _DocNum = "", int _UnlnkdId = 0)
        {
            InitializeComponent();

            Type = _Type;
            ReturnType = _ReturnType;
            RtnAllLines = _RtnAllLines;
            DocNum = _DocNum;
            UnlnkdId = _UnlnkdId;

            if(ReturnType == "LINKED" && DocNum != String.Empty)
            {
                btn_ChangePrice.IsEnabled = false;
                btn_ChangePrice.Background = Brushes.LightGray;
            }
            

        }

        string Type;
        string ReturnType;
        bool RtnAllLines;
        string DocNum;
        int UnlnkdId;


        /* Class Varaibles */
        /*----------------*/
        private int ItemId = 0;
        private string Currency = null;        
        /*----------------*/


        private void Item_Values()
        {
            string ItemName = null;
            string Price_Cur = null;
            Decimal Price = 0;

            try
            {
                string ConString = ConfigurationManager.ConnectionStrings["ConString"].ConnectionString;
                //string CmdString = string.Empty;
                using (SqlConnection con = new SqlConnection(ConString))
                {
                    con.Open();

                    SqlCommand cmd = new SqlCommand("stpPOS_Search_Values", con);
                    cmd.CommandType = CommandType.StoredProcedure;

                    cmd.Parameters.AddWithValue("@ItemId", ItemId);

                    SqlDataReader reader = cmd.ExecuteReader();

                    while (reader.Read())
                    {
                        ItemName = reader["ItemName"].ToString();
                        Price_Cur = reader["Price_Cur"].ToString();
                        Price = Decimal.Parse(reader["DiscountedPriceIncl"].ToString());
                        Currency = reader["Currency"].ToString();
                    }

                    con.Close();

                    tblItem_Value.Text = ItemName;
                    tblPrice_Value.Text = Price_Cur;

                    GlobalVaraibles._ItemSearch_Price = Price;


                }
            }
            catch (Exception e)
            {

                ErrorDialog errorDialog = new ErrorDialog("Error", e.Message);
                errorDialog.ShowDialog();
                //MessageBox.Show(e.Message, "Error");

            }


        }

        private void AddItem()
        {
            try
            {
                string ConString = ConfigurationManager.ConnectionStrings["ConString"].ConnectionString;
                using (SqlConnection con = new SqlConnection(ConString))
                {
                    con.Open();

                    SqlCommand cmd = new SqlCommand("stpPOS_Search_AddItem", con);
                    cmd.CommandType = CommandType.StoredProcedure;

                    cmd.Parameters.AddWithValue("@ItemId", ItemId);
                    cmd.Parameters.AddWithValue("@Price", GlobalVaraibles._ItemSearch_Price);
                    cmd.Parameters.AddWithValue("@UserId", UserId.User_Id);
                    cmd.Parameters.AddWithValue("@TerminalId", GlobalVaraibles._TerminalId);
                    //For Returns
                    cmd.Parameters.AddWithValue("@Type", Type);
                    cmd.Parameters.AddWithValue("@ReturnType", ReturnType);
                    cmd.Parameters.AddWithValue("@ReturnAllLines", RtnAllLines);
                    cmd.Parameters.AddWithValue("@DocNum", DocNum);
                    cmd.Parameters.AddWithValue("@UnlinkedHeaderId", UnlnkdId);

                    cmd.ExecuteNonQuery();

                    con.Close();

                    this.Close();

                }
            }
            catch (Exception e)
            {
                //MessageBox.Show(e.Message, "Error");
                ErrorDialog errorDialog = new ErrorDialog("Error", e.Message);
                errorDialog.ShowDialog();
            }

        }

        private void Btn_AddItem_Click(object sender, RoutedEventArgs e)
        {
            AddItem();
        }

        private void Btn_Cancel_Click(object sender, RoutedEventArgs e)
        {
            //Close
            this.Close();
        }

        private void Btn_ChangePrice_Click(object sender, RoutedEventArgs e)
        {
            if (ItemId != 0)
            {             
                PriceChange priceChange = new PriceChange(0, 0, ItemId, "SearchChange");
                priceChange.ShowDialog();

                if (GlobalVaraibles._ItemSearch_Price != 0)
                {
                    tblPrice_Value.Text = Currency + String.Format("{0:0.00}", Math.Round(GlobalVaraibles._ItemSearch_Price, 2));
                }
            }
        }

        private void Btn_Search_Click(object sender, RoutedEventArgs e)
        {
            //Search
            ItemSearchLookup itemSearchLookup = new ItemSearchLookup();
            itemSearchLookup.ShowDialog();
            ItemId = GlobalVaraibles._ItemId;
            Item_Values();

        }
    }
}
