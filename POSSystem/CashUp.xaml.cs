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
    /// Interaction logic for Shifts.xaml
    /// </summary>
    public partial class CashUp : Window
    {
        public CashUp()
        {
            InitializeComponent();
            FillDataGrid();
        }


        int Id = 0;

        
        private string GetUserName(string UserId)
        {
            string UserName = null;
            try
            {
                string ConString = ConfigurationManager.ConnectionStrings["ConString"].ConnectionString;
                //string CmdString = string.Empty;
                using (SqlConnection con = new SqlConnection(ConString))
                {
                    con.Open();

                    SqlCommand cmd = new SqlCommand("calcUserName", con);
                    cmd.CommandType = CommandType.StoredProcedure;

                    cmd.Parameters.AddWithValue("@UserId", UserId);

                    SqlDataReader reader = cmd.ExecuteReader();



                    while (reader.Read())
                    {
                        UserName = reader["UserName"].ToString();
                    }

                    con.Close();
                }
            }
            catch (Exception e)
            {
                MessageBox.Show(e.Message, "Error");
            }

            return UserName;
        }
        

        public void FillDataGrid()
        {
            string ConString = ConfigurationManager.ConnectionStrings["ConString"].ConnectionString;
            using (SqlConnection con = new SqlConnection(ConString))
            {
                SqlCommand cmd = new SqlCommand("stpCashUp_Shift_Select", con);
                cmd.CommandType = CommandType.StoredProcedure;
                cmd.Parameters.AddWithValue("@UserName", tbx_UserName.Text);
                cmd.Parameters.AddWithValue("@Date", DateStart.SelectedDate);


                SqlDataAdapter sda = new SqlDataAdapter(cmd);
                DataTable dt = new DataTable("Shifts");
                sda.Fill(dt);
                grdShifts.ItemsSource = dt.DefaultView;
            }
        }

        
        
      public void FillDataGrid_CashUp(int ShiftId)
      {
          string ConString = ConfigurationManager.ConnectionStrings["ConString"].ConnectionString;
          using (SqlConnection con = new SqlConnection(ConString))
          {
              SqlCommand cmd = new SqlCommand("stpCashUp_Denominations_Select", con);
              cmd.CommandType = CommandType.StoredProcedure;
              cmd.Parameters.AddWithValue("@ShiftId", ShiftId);               

              SqlDataAdapter sda = new SqlDataAdapter(cmd);
              DataTable dt = new DataTable("Cashup");
              sda.Fill(dt);
              grdCashUp.ItemsSource = dt.DefaultView;
          }
      }
        
      private void Insert_Denominations(int ShiftId)
      {
          try
            {
                string ConString = ConfigurationManager.ConnectionStrings["ConString"].ConnectionString;
                using (SqlConnection con = new SqlConnection(ConString))
                {
                    SqlCommand cmd = new SqlCommand("stpCashUp_Denominations_Insert", con);
                    cmd.CommandType = CommandType.StoredProcedure;
                    cmd.Parameters.AddWithValue("@ShiftId", ShiftId);

                    SqlDataAdapter sda = new SqlDataAdapter(cmd);
                    DataTable dt = new DataTable("Shifts");
                    sda.Fill(dt);
                    grdShifts.ItemsSource = dt.DefaultView;
                }
            }
            catch(Exception ex)
            {
                MessageBox.Show(ex.Message, "Error");
                    
            }
          
      }
        

        private void Denominations_Update(int Id, string Count)
      {
          decimal Cnt = 0;
          try
          {
              string ConString = ConfigurationManager.ConnectionStrings["ConString"].ConnectionString;
              using (SqlConnection con = new SqlConnection(ConString))
              {
                  con.Open();

                  SqlCommand cmd = new SqlCommand("stpCashUp_Denominations_Update", con);
                  cmd.CommandType = CommandType.StoredProcedure;

                  cmd.Parameters.AddWithValue("@Id", Id);

                  if (Count == null || Count == string.Empty)
                  {
                      cmd.Parameters.AddWithValue("@Count", Cnt).Value = DBNull.Value;
                  }
                  else
                  {
                      cmd.Parameters.AddWithValue("@Count", Int32.Parse(Count));
                  }


                  cmd.ExecuteNonQuery();

                  con.Close();

              }
          }
          catch (Exception e)
          {
              MessageBox.Show(e.Message, "Error");
          }
      }

        private void CardMachineTotal_Update(int Id, string Total)
        {
            decimal Cnt = 0;
            try
            {
                string ConString = ConfigurationManager.ConnectionStrings["ConString"].ConnectionString;
                using (SqlConnection con = new SqlConnection(ConString))
                {
                    con.Open();

                    SqlCommand cmd = new SqlCommand("stpCashUp_CardMachineTotal_Update", con);
                    cmd.CommandType = CommandType.StoredProcedure;

                    cmd.Parameters.AddWithValue("@Id", Id);

                    if (Total == null || Total == string.Empty)
                    {
                        cmd.Parameters.AddWithValue("@Total", Cnt).Value = DBNull.Value;
                    }
                    else
                    {
                        cmd.Parameters.AddWithValue("@Total", Decimal.Parse(Total));
                    }


                    cmd.ExecuteNonQuery();

                    con.Close();

                }
            }
            catch (Exception e)
            {
                MessageBox.Show(e.Message, "Error");
            }
        }

        private void Denominations_Confirm(int Id)
        {           
            try
            {
                string ConString = ConfigurationManager.ConnectionStrings["ConString"].ConnectionString;
                using (SqlConnection con = new SqlConnection(ConString))
                {
                    con.Open();

                    SqlCommand cmd = new SqlCommand("stpCashUp_Denominations_Confirm", con);
                    cmd.CommandType = CommandType.StoredProcedure;

                    cmd.Parameters.AddWithValue("@ShiftId", Id);

                    cmd.ExecuteNonQuery();

                    con.Close();

                }
            }
            catch (Exception e)
            {
                MessageBox.Show(e.Message, "Error");
            }
        }

        private void MenuItem_Click(object sender, RoutedEventArgs e)
      {
          //Cash Up Shift
          if(Id > 0)
          {
              Insert_Denominations(Id);
              FillDataGrid_CashUp(Id);
              FillDataGrid();
          }


      }

        

    private void tbx_UserName_KeyUp(object sender, KeyEventArgs e)
    {
        FillDataGrid();
    }

    private void DateStart_SelectedDateChanged(object sender, SelectionChangedEventArgs e)
    {
        FillDataGrid();
    }
      
        private void grdShifts_MouseLeftButtonUp(object sender, MouseButtonEventArgs e)
      {
          //Selected
          DataRowView dataRow = (DataRowView)grdShifts.SelectedItem;

          if (dataRow != null)
          {
              Id = Int32.Parse(dataRow.Row.ItemArray[0].ToString());

              FillDataGrid_CashUp(Id);
          }


      }

        

      private void grdCashUp_SelectedCellsChanged(object sender, SelectedCellsChangedEventArgs e)
      {
          foreach (System.Data.DataRowView dr in grdCashUp.ItemsSource)
          {
              Denominations_Update(Int32.Parse(dr.Row.ItemArray[0].ToString()), dr.Row.ItemArray[3].ToString());
          }

          grdCashUp.BeginEdit();

          
      }

        private void MenuItem_Click_1(object sender, RoutedEventArgs e)
        {
            //Confirm Denominations            
            MessageBoxResult messageBoxResult = System.Windows.MessageBox.Show("Are you sure you want to confirm the denominations and complete the Cash Up?", "Denomination Confirmation", System.Windows.MessageBoxButton.YesNo);

            if (messageBoxResult == MessageBoxResult.Yes)
            {
                DataRowView dataRow = (DataRowView)grdShifts.SelectedItem;
                if (dataRow != null)
                {
                    Id = Int32.Parse(dataRow.Row.ItemArray[0].ToString());
                    Denominations_Confirm(Id);

                    FillDataGrid_CashUp(-1);
                    FillDataGrid();
                }
            }

        }

        private void grdShifts_SelectedCellsChanged(object sender, SelectedCellsChangedEventArgs e)
        {
            //Update CardMachineTotal
            foreach (System.Data.DataRowView dr in grdShifts.ItemsSource)
            {
                CardMachineTotal_Update(Int32.Parse(dr.Row.ItemArray[0].ToString()), dr.Row.ItemArray[6].ToString());
            }

            grdShifts.BeginEdit();
        }
    }
}
