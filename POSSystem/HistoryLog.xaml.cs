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
using Microsoft.Win32;
using System.IO;
//using Microsoft.Office;
using System.Data.OleDb;
using ClosedXML.Excel;

namespace POSSystem
{
    /// <summary>
    /// Interaction logic for HistoryLog.xaml
    /// </summary>
    public partial class HistoryLog : System.Windows.Window
    {
        

        public HistoryLog()
        {
            InitializeComponent();
            ActionLookupFill();
            cbx_Action.SelectedItem = "All";
            FillDataGrid();
        }

        
        public void FillDataGrid()
        {
            try
            {
                string action; 
                if(cbx_Action.SelectedItem.ToString().Equals("All"))
                {
                    action = "";
                }
                else
                {
                    action = cbx_Action.SelectedItem.ToString();
                }

                string ConString = ConfigurationManager.ConnectionStrings["ConString"].ConnectionString;
                using (SqlConnection con = new SqlConnection(ConString))
                {
                    SqlCommand cmd = new SqlCommand("stpHistoryLog_Select", con);
                    cmd.CommandType = CommandType.StoredProcedure;
                    cmd.Parameters.AddWithValue("@DateTime", datepicker.Text);
                    cmd.Parameters.AddWithValue("@UserName", tbx_Name.Text);
                    cmd.Parameters.AddWithValue("@Action", action);
                    cmd.Parameters.AddWithValue("@Description", tbx_Description.Text);
                    cmd.Parameters.AddWithValue("@FromValue", tbx_FromValue.Text);
                    cmd.Parameters.AddWithValue("@ToValue", tbx_ToValue.Text);

                    SqlDataAdapter sda = new SqlDataAdapter(cmd);
                    System.Data.DataTable dt = new System.Data.DataTable("HistoryLog");
                    sda.Fill(dt);
                    grdHistoryLog.ItemsSource = dt.DefaultView;
                }

            }catch(Exception e)
            {
                MessageBox.Show(e.Message, "Error");
            }
        }

        private void ActionLookupFill()
        {
           
            try
            {
                string ConString = ConfigurationManager.ConnectionStrings["ConString"].ConnectionString;
                //string CmdString = string.Empty;
                using (SqlConnection con = new SqlConnection(ConString))
                {
                    con.Open();

                    SqlCommand cmd = new SqlCommand("lkpHistoryLog_Actions", con);
                    cmd.CommandType = CommandType.StoredProcedure;

                    SqlDataReader reader = cmd.ExecuteReader();

                    while (reader.Read())
                    {
                       cbx_Action.Items.Add(reader["Action"].ToString());
                    }                    

                    con.Close();
                }
            }
            catch (Exception e)
            {
                MessageBox.Show(e.Message, "Error");
            }
        }
        /*
        private void ExportToExcelAndCsv()
        {
            string filename = "HistoryLog "+ DateTime.Now.ToString("MM-dd-yyyy");
            SaveFileDialog saveFileDialog = new SaveFileDialog();
            saveFileDialog.Filter = "Excel Workbook (*.xlsx)|*.xls";
            saveFileDialog.InitialDirectory = Environment.GetFolderPath(Environment.SpecialFolder.MyDocuments);
            saveFileDialog.FileName = filename;
            saveFileDialog.ShowDialog();

            string directory = saveFileDialog.InitialDirectory.ToString()+"/"+ saveFileDialog.SafeFileName + "";           

            grdHistoryLog.SelectAllCells();
            grdHistoryLog.ClipboardCopyMode = DataGridClipboardCopyMode.IncludeHeader;
            ApplicationCommands.Copy.Execute(null, grdHistoryLog);
            String resultat = (string)Clipboard.GetData(DataFormats.CommaSeparatedValue);
            String result = (string)Clipboard.GetData(DataFormats.Text);
            grdHistoryLog.UnselectAllCells();
            StreamWriter file1 = new StreamWriter(directory);
            file1.WriteLine(result.Replace(',', ' '));
            file1.Close();
            FileInfo fileInfo = new FileInfo(directory);

            ConvertXLS_XLSX(fileInfo);
            if (File.Exists(System.IO.Path.Combine(saveFileDialog.InitialDirectory.ToString() + "/", saveFileDialog.SafeFileName)))
            {
                // If file found, delete it    
                File.Delete(System.IO.Path.Combine(saveFileDialog.InitialDirectory.ToString() + "/", saveFileDialog.SafeFileName));      
            }

            MessageBox.Show("Export to excel completed.", "Info");
        }
        */
       /*
        public static string ConvertXLS_XLSX(FileInfo file)
        {
            var app = new Microsoft.Office.Interop.Excel.Application();
            var xlsFile = file.FullName;
            var wb = app.Workbooks.Open(xlsFile);
            var xlsxFile = xlsFile + "x";
            wb.SaveAs(Filename: xlsxFile, FileFormat: Microsoft.Office.Interop.Excel.XlFileFormat.xlOpenXMLWorkbook);
            wb.Close();
            app.Quit();
            return xlsxFile;
        }       
       */
        private void BtnCancel_Click(object sender, RoutedEventArgs e)
        {
            this.Close();
        }

        private void Datepicker_CalendarClosed(object sender, RoutedEventArgs e)
        {
            FillDataGrid();
        }

        private void Tbx_Name_KeyUp(object sender, KeyEventArgs e)
        {
            FillDataGrid();
        }
               
        private void Tbx_Description_KeyUp(object sender, KeyEventArgs e)
        {
            FillDataGrid();
        }

        private void Tbx_FromValue_KeyUp(object sender, KeyEventArgs e)
        {
            FillDataGrid();
        }

        private void Tbx_ToValue_KeyUp(object sender, KeyEventArgs e)
        {
            FillDataGrid();
        }

        private void Datepicker_KeyUp(object sender, KeyEventArgs e)
        {

            if (datepicker.Text == null || datepicker.Text == "")
            {
                FillDataGrid();
            }                   

        }
       
        private void Cbx_Action_DropDownClosed(object sender, EventArgs e)
        {
            FillDataGrid();
        }

        private void MenuItem_Click(object sender, RoutedEventArgs e)
        {
            //ExportToExcelAndCsv();
        }

        private void Button_Click(object sender, RoutedEventArgs e)
        {
            string startupPath1 = System.IO.Directory.GetCurrentDirectory();
            string startupPath2 = Environment.CurrentDirectory;

          

            MessageBox.Show(startupPath1 +"\n"+ startupPath2);
        }

        private static void ExportDataSet(DataSet ds, string destination)
        {
            var workbook = new ClosedXML.Excel.XLWorkbook();
            foreach (DataTable dt in ds.Tables)
            {
                var worksheet = workbook.Worksheets.Add(dt.TableName);               
                worksheet.Cell(1, 1).InsertTable(dt);
                worksheet.Columns().AdjustToContents();
                worksheet.Tables.FirstOrDefault().Theme = XLTableTheme.None;
                worksheet.Tables.FirstOrDefault().ShowAutoFilter = false;
            }
            
            workbook.SaveAs(destination);
            workbook.Dispose();
        }
                

        private void MenuItem_Click_1(object sender, RoutedEventArgs e)
        {
                string action;
                if (cbx_Action.SelectedItem.ToString().Equals("All"))
                {
                    action = "";
                }
                else
                {
                    action = cbx_Action.SelectedItem.ToString();
                }

            string ConString = ConfigurationManager.ConnectionStrings["ConString"].ConnectionString;
            using (SqlConnection con1 = new SqlConnection(ConString))
            {
                SqlCommand cmd1 = new SqlCommand("stpHistoryLog_Select", con1);
                cmd1.CommandType = CommandType.StoredProcedure;
                cmd1.Parameters.AddWithValue("@DateTime", datepicker.Text);
                cmd1.Parameters.AddWithValue("@UserName", tbx_Name.Text);
                cmd1.Parameters.AddWithValue("@Action", action);
                cmd1.Parameters.AddWithValue("@Description", tbx_Description.Text);
                cmd1.Parameters.AddWithValue("@FromValue", tbx_FromValue.Text);
                cmd1.Parameters.AddWithValue("@ToValue", tbx_ToValue.Text);

                ///--------------------------------------///  

                 DataSet ds1 = new DataSet("HistoryLog_DataSet");
                 SqlDataAdapter sda = new SqlDataAdapter(cmd1);
                 System.Data.DataTable dt1 = new System.Data.DataTable("HistoryLog");
                 sda.Fill(dt1);
                 ds1.Tables.Add(dt1);

                 string filename = "HistoryLog " + DateTime.Now.ToString("MM-dd-yyyy");
                 SaveFileDialog saveFileDialog = new SaveFileDialog();
                 saveFileDialog.Filter = "Excel Workbook (*.xlsx)|*.xlsx";
                 saveFileDialog.InitialDirectory = Environment.GetFolderPath(Environment.SpecialFolder.MyDocuments);
                 saveFileDialog.FileName = filename;

                 //saveFileDialog.ShowDialog();

                 Nullable<bool> result = saveFileDialog.ShowDialog();
                 if (result == true)
                {
                    string directory = saveFileDialog.InitialDirectory.ToString() + "/" + saveFileDialog.SafeFileName + "";
                    if (!directory.Equals(string.Empty) || directory != null)
                    {
                        ExportDataSet(ds1, directory);
                    }
                }
                    
                    
            }                           

           
        }
    }
}
