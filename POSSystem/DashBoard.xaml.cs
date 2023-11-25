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
using System.Collections.ObjectModel;
using POSSystem_Manager;
using System.IO;
using System.Diagnostics;

namespace POSSystem
{
    /// <summary>
    /// Interaction logic for DashBoard.xaml
    /// </summary>
    public partial class DashBoard : Window
    {
        public DashBoard()
        {
            InitializeComponent();
            
            this.Title = "POS System.   Logged in: "+GetUserName(UsrId);

            Messages();

            FillLookup();

            Cmbx.SelectedValue = 1; //Default (Last 7 Days)
            DateFrom.SelectedDate = DateTime.Today;
            DateTo.SelectedDate = DateTime.Today;

            Graph();

        }
                
       

        private Boolean SecurityAccess(string ObjectId, string _UserId)
        {
            Boolean Result = false;
            try
            {
                string ConString = ConfigurationManager.ConnectionStrings["ConString"].ConnectionString;              
                using (SqlConnection con = new SqlConnection(ConString))
                {
                    con.Open();

                    SqlCommand cmd = new SqlCommand("stpSecurityAccess", con);
                    cmd.CommandType = CommandType.StoredProcedure;

                    cmd.Parameters.AddWithValue("@ObjectId", ObjectId);
                    cmd.Parameters.AddWithValue("@UserId", _UserId);

                    SqlDataReader reader = cmd.ExecuteReader();

                    while (reader.Read())
                    {
                        Result = bool.Parse(reader["Result"].ToString());
                    }

                    con.Close();

                    if(!Result)
                    {
                        MessageBox.Show("User does not have access.", "Error");
                    }
                }
            }
            catch (Exception e)
            {
                MessageBox.Show(e.Message, "Error");
            }

            return Result;
        }

        private string UsrId = UserId.User_Id;

        //public SeriesCollection SeriesCollection { get; private set; }
        //public string[] Labels { get; private set; }
        //public Func<object, object> YFormatter { get; private set; }

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

        private string GetCurrencySign()
        {
            string CurrencySign = "";
            try
            {
                string ConString = ConfigurationManager.ConnectionStrings["ConString"].ConnectionString;
                //string CmdString = string.Empty;
                using (SqlConnection con = new SqlConnection(ConString))
                {
                    con.Open();

                    SqlCommand cmd = new SqlCommand("stpCompanyInformation_Select", con);
                    cmd.CommandType = CommandType.StoredProcedure;

                    SqlDataReader reader = cmd.ExecuteReader();


                    while (reader.Read())
                    {
                        CurrencySign = reader["CurrencySign"].ToString();
                    }

                    con.Close();
                }
            }
            catch (Exception e)
            {
                MessageBox.Show(e.Message, "Error");
            }

            return CurrencySign;
        }

        private void Messages()
        {
            listBox.Items.Clear();

            try
            {
                string ConString = ConfigurationManager.ConnectionStrings["ConString"].ConnectionString;                
                using (SqlConnection con = new SqlConnection(ConString))
                {
                    con.Open();

                    SqlCommand cmd = new SqlCommand("stpPOS_Messages", con);
                    cmd.CommandType = CommandType.StoredProcedure;                    

                    SqlDataReader reader = cmd.ExecuteReader();

                    while (reader.Read())
                    {
                        listBox.Items.Add(reader["Message"].ToString());
                    }

                    con.Close();
                }
            }
            catch (Exception e)
            {
                MessageBox.Show(e.Message, "Error");
            }            
        }

        private void FillLookup()
        {
            try
            {
                string ConString = ConfigurationManager.ConnectionStrings["ConString"].ConnectionString;               
                using (SqlConnection con = new SqlConnection(ConString))
                {
                    con.Open();

                    SqlCommand cmd = new SqlCommand("lkpDashBoardGraphOptions", con);
                    cmd.CommandType = CommandType.StoredProcedure;

                    //SqlDataReader reader = cmd.ExecuteReader();

                    SqlDataAdapter sda = new SqlDataAdapter(cmd);
                    DataTable dt = new DataTable("DashBoardGraphOptions");
                    sda.Fill(dt);
                    Cmbx.ItemsSource = dt.DefaultView;
                    con.Close();
                }
            }
            catch (Exception e)
            {
                MessageBox.Show(e.Message, "Error");
            }
        }

        private void CanvasText(double x, double y, string text, Color color, Canvas canvas)
        {

            TextBlock textBlock = new TextBlock();
            textBlock.Text = text;
            textBlock.Foreground = new SolidColorBrush(color);
            textBlock.FontWeight = FontWeights.Bold;


            Canvas.SetLeft(textBlock, x);
            Canvas.SetTop(textBlock, y);

            canvas.Children.Add(textBlock);           

        }

        private double DistanceBetween2Points(double X1, double Y1, double X2, double Y2)
        {
            return Math.Sqrt(Math.Pow((X2 - X1),2) + Math.Pow((Y2 - Y1),2));
        }

        private void Graph()
        {
            int XMarkerCount = 0; //= 15;
            int YMarkerCount = 10;

            //Get Data 
            List<string> SalesTotal_list = new List<string>();
            List<string> Date_list = new List<string>();

            int TotalMin = 0;
            int TotalMax = 0;
            int Interval = 0;

            try
            {
                string ConString = ConfigurationManager.ConnectionStrings["ConString"].ConnectionString;
                using (SqlConnection con = new SqlConnection(ConString))
                {
                    con.Open();

                    SqlCommand cmd = new SqlCommand("stpDashBoard_SalesGraph_Values", con);
                    cmd.CommandType = CommandType.StoredProcedure;

                    cmd.Parameters.AddWithValue("@Options", Cmbx.SelectedValue);
                    cmd.Parameters.AddWithValue("@DateFrom", DateFrom.SelectedDate);
                    cmd.Parameters.AddWithValue("@DateTo", DateTo.SelectedDate);

                    SqlDataReader reader = cmd.ExecuteReader();

                    //int RecordCount = 0;

                    double SalesTotal;
                    string SalesDate;

                    List<string> y_axis_Dates = new List<string>();
                    List<int> x_axis_SaleTotals = new List<int>();

                    while (reader.Read())
                    {
                        SalesTotal = Double.Parse(reader["SalesTotal"].ToString());
                        SalesDate = reader["Date"].ToString();

                        TotalMin = Int32.Parse(reader["TotalMIN"].ToString());
                        TotalMax = Int32.Parse(reader["TotalMAX"].ToString());
                        Interval = Int32.Parse(reader["Interval"].ToString());

                        SalesTotal_list.Add(SalesTotal.ToString());
                        Date_list.Add(SalesDate);

                        XMarkerCount += 1;
                    }

                    con.Close();
                }
            }
            catch (Exception e)
            {
                MessageBox.Show(e.Message, "Error");
            }



            //------------------------------------

            string[] SalesTotal_Array = SalesTotal_list.ToArray();
            string[] Date_Array = Date_list.ToArray();
            int[] X_Axis_Markers = new int[XMarkerCount];

            int Total_Numbers = TotalMax;

            Canvas canvas = Canvas_Graph;
            canvas.Children.Clear();
            
            Line line_X = new Line();
            Line line_Y = new Line();

            double LineMargin = 60;
            int StrokeThickness = 3;

            line_X.Stroke = Brushes.Black;
            line_X.StrokeThickness = StrokeThickness;
            line_Y.Stroke = Brushes.Black;
            line_Y.StrokeThickness = StrokeThickness;

            // X Graph Line
            line_X.X1 = LineMargin;
            line_X.Y1 = canvas.ActualHeight - LineMargin;
            line_X.X2 = canvas.ActualWidth - LineMargin;
            line_X.Y2 = canvas.ActualHeight - LineMargin;
            canvas.Children.Add(line_X);

            // Y Graph Line
            line_Y.X1 = LineMargin;
            line_Y.Y1 = LineMargin;
            line_Y.X2 = LineMargin;            
            line_Y.Y2 = canvas.ActualHeight - LineMargin;
            canvas.Children.Add(line_Y);


            //-------------------------------------------\\            

            double Line_X_Lenght = canvas.ActualWidth - (LineMargin * 2);
            double Mark_X_Interval = Line_X_Lenght / XMarkerCount;

            double Line_Y_Lenght = canvas.ActualHeight - (LineMargin * 2);
            double Mark_Y_Interval = Line_Y_Lenght / YMarkerCount;

            CanvasText(0,0, "SALES TOTAL ("+ GetCurrencySign() + ")", Color.FromRgb(0, 0, 0), canvas);

            //Line X markers
            for (int i = 1; i <= XMarkerCount; i ++)
            {
                //Grid Lines
                Line line_X_Grid = new Line();
                line_X_Grid.Stroke = Brushes.LightGray;
                line_X_Grid.StrokeThickness = StrokeThickness/2;

                line_X_Grid.X1 = line_X.X1 + (Mark_X_Interval * i);
                line_X_Grid.Y1 = LineMargin;
                line_X_Grid.X2 = line_X.X1 + (Mark_X_Interval * i);
                line_X_Grid.Y2 = line_X.Y1 + (StrokeThickness / 2);
                canvas.Children.Add(line_X_Grid);

                //Marker Lines
                Line line_X_marks = new Line();
                line_X_marks.Stroke = Brushes.Black;
                line_X_marks.StrokeThickness = StrokeThickness;                

                line_X_marks.X1 = line_X.X1 + (Mark_X_Interval * i);
                line_X_marks.Y1 = line_X.Y1 - 10;
                line_X_marks.X2 = line_X.X1 + (Mark_X_Interval * i);
                line_X_marks.Y2 = line_X.Y1 + (StrokeThickness/2);
                canvas.Children.Add(line_X_marks);

                X_Axis_Markers[i - 1] = (int)line_X_marks.X1;

                //Text
                CanvasText((line_X_marks.X1 - 30), (line_X_marks.Y2 + 10), Date_Array[i-1], Color.FromRgb(0, 0, 0), canvas);                              

            }
            // Line Y markers
            for (int i = 0; i <= YMarkerCount; i++)
            {
                //Grid Lines
                if(i < YMarkerCount)
                {
                    Line line_Y_Grid = new Line();
                    line_Y_Grid.Stroke = Brushes.LightGray;
                    line_Y_Grid.StrokeThickness = StrokeThickness / 2;

                    line_Y_Grid.X1 = line_Y.X1 - (StrokeThickness / 2);
                    line_Y_Grid.Y1 = line_Y.Y1 + (Mark_Y_Interval * i);
                    line_Y_Grid.X2 = (canvas.ActualWidth - LineMargin);
                    line_Y_Grid.Y2 = line_Y.Y1 + (Mark_Y_Interval * i);
                    canvas.Children.Add(line_Y_Grid);
                }                

                //Marker Lines
                Line line_Y_marks = new Line();
                line_Y_marks.Stroke = Brushes.Black;
                line_Y_marks.StrokeThickness = StrokeThickness;

                line_Y_marks.X1 = line_Y.X1 - (StrokeThickness/2);
                line_Y_marks.Y1 = line_Y.Y1 + (Mark_Y_Interval * i);
                line_Y_marks.X2 = line_Y.X1 + 10;
                line_Y_marks.Y2 = line_Y.Y1 + (Mark_Y_Interval * i);
                canvas.Children.Add(line_Y_marks);

                //Text
               
                CanvasText((line_Y_marks.X1 - LineMargin+5), (line_Y_marks.Y1-10), Total_Numbers.ToString(), Color.FromRgb(0, 0, 0), canvas);
                Total_Numbers = Total_Numbers - Interval;
            }


            //Draw Graph Line (Plot Points)            

            /*
                string[] SalesTotal_Array = SalesTotal_list.ToArray();
                string[] Date_Array = Date_list.ToArray();
             */

            List<int> TextPoint_X = new List<int>();
            List<int> TextPoint_Y = new List<int>();              
            

            //double Y_axis_lenght = line_Y.Y2;
            double Y_axis_lenght = DistanceBetween2Points(line_Y.X1, line_Y.Y1, line_Y.X2, line_Y.Y2);

            int FromX = (int)LineMargin;
            int FromY = (int)Y_axis_lenght + (int)LineMargin;

            int CurrentX = 0;
            int CurrentY = 0;

            for (int i = 0; i < Date_Array.Length; i++)
            {
                double NumPercentage = (Double.Parse(SalesTotal_Array[i]) - TotalMin) / (TotalMax - TotalMin) * 100;

                CurrentX = X_Axis_Markers[i];
                CurrentY = (int)(Y_axis_lenght - ((NumPercentage / 100.0) * Y_axis_lenght)) + (int)LineMargin;
               

                //Draw Line
                Line line_graph = new Line();
                line_graph.Stroke = Brushes.Red;
                line_graph.StrokeThickness = StrokeThickness;

                line_graph.X1 = FromX;
                line_graph.Y1 = FromY;
                line_graph.X2 = CurrentX;
                line_graph.Y2 = CurrentY;

                canvas.Children.Add(line_graph);

                //Text               
                TextPoint_X.Add(CurrentX);
                TextPoint_Y.Add(CurrentY);               

                //Dot
                int dotSize = 10;               
                Ellipse currentDot = new Ellipse();
                currentDot.Stroke = new SolidColorBrush(Colors.Green);
                currentDot.StrokeThickness = 3;
                Canvas.SetZIndex(currentDot, 3);
                currentDot.Height = dotSize;
                currentDot.Width = dotSize;
                currentDot.Fill = new SolidColorBrush(Colors.Green);
                currentDot.Margin = new Thickness(CurrentX-4, CurrentY-4, 0, 0); // Sets the position.
                canvas.Children.Add(currentDot);                
                //------------------------------

                FromX = CurrentX;
                FromY = CurrentY;
                
            }

            int[] PointX = TextPoint_X.ToArray();
            int[] PointY = TextPoint_Y.ToArray();

            for(int i = 0; i < SalesTotal_Array.Length; i++)
            {
                //Text
                CanvasText(PointX[i]+6, PointY[i]-8, SalesTotal_Array[i], Color.FromRgb(0, 0, 0), canvas);
            }            

        }

        private void Button_Click(object sender, RoutedEventArgs e)
        {
            Graph(); 
        }

       
        public string[] Labels { get; set; }
        public Func<double, string> YFormatter { get; set; }

        private void MenuItem_Click(object sender, RoutedEventArgs e)
        {
            //Exit
            this.Close();
        }

        private void MenuItemLogout_Click(object sender, RoutedEventArgs e)
        {
            //Logout
            MainWindow mainWindow = new MainWindow();
            mainWindow.Show();
            UserId.User_Id = "";
            this.Close();
        }

        private void Btn_UserManagement_Click(object sender, RoutedEventArgs e)
        {
            //Users
            UserManagement userManagement = new UserManagement();
            this.Hide();
            userManagement.ShowDialog();
            this.Show();
        }

        private void MenuItem_Click_1(object sender, RoutedEventArgs e)
        {
            //History Log            
            if (SecurityAccess(SecurityObjects.HistoryLog, UserId.User_Id))
            {
                HistoryLog historyLog = new HistoryLog();
                this.Hide();
                historyLog.ShowDialog();
                this.Show();
                Messages();
            }           
        }

        private void MenuItem_Click_2(object sender, RoutedEventArgs e)
        {
            //Security --Role Groups
            if (SecurityAccess(SecurityObjects.Security, UserId.User_Id))
            {
                Security_RoleGroups rolegroups = new Security_RoleGroups();
                this.Hide();
                rolegroups.ShowDialog();
                this.Show();
                Messages();
            }            
        }

        private void Btn_StockManagement_Click(object sender, RoutedEventArgs e)
        {
            //Item Master
            StockManagement stockManagement = new StockManagement();
            this.Hide();
            stockManagement.ShowDialog();
            this.Show();
        }

        private void MenuItem_Click_3(object sender, RoutedEventArgs e)
        {
            //Users
            if (SecurityAccess(SecurityObjects.Users, UserId.User_Id))
            {
                UserManagement userManagement = new UserManagement();
                this.Hide();
                userManagement.ShowDialog();
                this.Show();
                Messages();
            }      
        }

        private void MenuItem_Click_4(object sender, RoutedEventArgs e)
        {
            //Item Master
            if (SecurityAccess(SecurityObjects.ItemMaster, UserId.User_Id))
            {
                StockManagement stockManagement = new StockManagement();
                this.Hide();
                stockManagement.ShowDialog();
                this.Show();
                Messages();
            }   
        }

        private void MenuItem_Click_5(object sender, RoutedEventArgs e)
        {
            //Stock Receive
            if (SecurityAccess(SecurityObjects.StockReceive, UserId.User_Id))
            {
                StockReceive stockReceive = new StockReceive();
                this.Hide();
                stockReceive.ShowDialog();
                this.Show();
                Messages();
            } 
        }

        private void MenuItem_Click_6(object sender, RoutedEventArgs e)
        {
            //Company Info
            if (SecurityAccess(SecurityObjects.CompanyInformation, UserId.User_Id))
            {
                CompanyInfo companyInfo = new CompanyInfo();
                this.Hide();
                companyInfo.ShowDialog();
                this.Show();
                Messages();
            }            
        }

        private void MenuItem_Click_7(object sender, RoutedEventArgs e)
        {
            //Item Groups
            if (SecurityAccess(SecurityObjects.ItemGroups, UserId.User_Id))
            {
                ItemGroups itemGroups = new ItemGroups();
                this.Hide();
                itemGroups.ShowDialog();
                this.Show();
                Messages();
            }            
        }

        private void MenuItem_Click_8(object sender, RoutedEventArgs e)
        {
            //Suppliers
            if (SecurityAccess(SecurityObjects.Suppliers, UserId.User_Id))
            {
                Suppliers suppliers = new Suppliers();
                this.Hide();
                suppliers.ShowDialog();
                this.Show();
                Messages();
            }    
        }

        private void MenuItem_Click_9(object sender, RoutedEventArgs e)
        {
            //Stock Take
            if (SecurityAccess(SecurityObjects.StockTake, UserId.User_Id))
            {
                StockTake stockTake = new StockTake();
                this.Hide();
                stockTake.ShowDialog();
                this.Show();
                Messages();
            }

        }

        private void MenuItem_Click_10(object sender, RoutedEventArgs e)
        {
            //Printers
            if (SecurityAccess(SecurityObjects.Printers, UserId.User_Id))
            {
                Printers printers = new Printers();
                this.Hide();
                printers.ShowDialog();
                this.Show();
                Messages();
            }
        }

        private void MenuItem_Click_11(object sender, RoutedEventArgs e)
        {
            //Terminals
            if (SecurityAccess(SecurityObjects.Terminals, UserId.User_Id))
            {
                Terminals terminals = new Terminals();
                this.Hide();
                terminals.ShowDialog();
                this.Show();
                Messages();
            }
        }

        private void Window_ContextMenuClosing(object sender, ContextMenuEventArgs e)
        {
            MainWindow mainWindow = new MainWindow();
            mainWindow.Close();
        }

        private void MenuLaunchPOS_Click(object sender, RoutedEventArgs e)
        {
            string startupPath = System.IO.Path.Combine(Directory.GetParent(System.IO.Directory.GetCurrentDirectory()).Parent.Parent.Parent.FullName);
            startupPath = startupPath + @"\POSSystem\POSSystem_Retail\bin\Debug\POSSystem_Retail.exe";
           
            Process.Start(startupPath);
        }

        private void Cmbx_SelectionChanged(object sender, SelectionChangedEventArgs e)
        {
            
            Graph();
            
            /* if (Cmbx.SelectedIndex == 1)
            {

                DateFrom.SelectedDate = DateTime.Now.Subtract(DateTime.7);
                DateTo.SelectedDate = DateTime.Today;
            }*/
        }

        private void Window_SizeChanged(object sender, SizeChangedEventArgs e)
        {
            Graph();
        }

        private void MenuItem_Click_12(object sender, RoutedEventArgs e)
        {
            Shifts shifts = new Shifts();
            shifts.ShowDialog();
        }

        private void MenuItem_Click_13(object sender, RoutedEventArgs e)
        {
            //Unit of Measures (UoM)
            UnitOfMeasures uom = new UnitOfMeasures();
            uom.ShowDialog();
        }

        private void MenuItem_Click_14(object sender, RoutedEventArgs e)
        {
            //Denomiations
            Denominations denominations = new Denominations();
            denominations.ShowDialog();

        }

        private void MenuItem_Click_15(object sender, RoutedEventArgs e)
        {
            //Cash Up
            CashUp cashUp = new CashUp();
            cashUp.ShowDialog();
            Messages();
        }

        private void MenuItem_Click_16(object sender, RoutedEventArgs e)
        {
            //Sales History
            SalesHistory salesHistory = new SalesHistory(); 
            salesHistory.ShowDialog();
            Messages();
        }

        private void DateFrom_SelectedDateChanged(object sender, SelectionChangedEventArgs e)
        {
            Graph();
        }

        private void DateTo_SelectedDateChanged(object sender, SelectionChangedEventArgs e)
        {
            Graph();
        }

        private void MenuItem_Click_17(object sender, RoutedEventArgs e)
        {
            MessageBox.Show("Incomplete");
        }
    }
}
