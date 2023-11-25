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
using System.Windows.Controls.Primitives;
using System.Windows.Data;
using System.Windows.Documents;
using System.Windows.Input;
using System.Windows.Media;
using System.Windows.Media.Imaging;
using System.Windows.Navigation;
using System.Windows.Shapes;


namespace POSSystem_Retail
{
    /// <summary>
    /// Interaction logic for ItemButtons.xaml
    /// </summary>
    public partial class ItemButtons : Window
    {
        public ItemButtons(string _Type = "SALE", string _ReturnType = "", bool _RtnAllLines = false, string _DocNum = "", int _UnlnkdId = 0)
        {
            InitializeComponent();

            Type = _Type;
            ReturnType = _ReturnType;
            RtnAllLines = _RtnAllLines;
            DocNum = _DocNum;
            UnlnkdId = _UnlnkdId;
        }

        string Type;
        string ReturnType;
        bool RtnAllLines;
        string DocNum;
        int UnlnkdId;

        private int ItemGroupId = 0;

        double GetWindowHeight()
        {
            return Main_Window.Height;
        }

        double GetWindowWidth()
        {
            return Main_Window.Width;
        }

        double GetGridWidth()
        {
            if (MainGrid.ActualWidth == 0)
            {
                return GetWindowWidth() - 135;
            }
            else
            {
                return MainGrid.ActualWidth - 135;
            }

        }

        double GetGridHeight()
        {
            return MainGrid.ActualHeight;
        }

        private void AddItem(int _ItemId)
        {
            try
            {
                string ConString = ConfigurationManager.ConnectionStrings["ConString"].ConnectionString;
                using (SqlConnection con = new SqlConnection(ConString))
                {
                    con.Open();

                    SqlCommand cmd = new SqlCommand("stpPOS_Search_AddItem", con);
                    cmd.CommandType = CommandType.StoredProcedure;
                    //For Sales
                    cmd.Parameters.AddWithValue("@ItemId", _ItemId);
                    cmd.Parameters.AddWithValue("@Price", null);
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

        protected void button_Click(object sender, EventArgs e)
        {
            Button button = sender as Button;
            ItemGroupId = Int32.Parse(button.Name.Replace("_", string.Empty));

            MainGrid.Children.Clear();
            AddGroupContent();
            AddContent();
        }

        protected void ItemButton_Click(object sender, EventArgs e)
        {
            Button button = sender as Button;
            ItemId = Int32.Parse(button.Name.Replace("_", string.Empty));
            AddItem(ItemId);
            GlobalVaraibles.ItemButons_Canceled = false;
            this.Close();

          

        }

        protected void BackButton_Click(object sender, EventArgs e)
        {
            GlobalVaraibles.ItemButons_Canceled = true;
            this.Close();
        }

        private void AddGroupContent()
        {
            Style style = new Style
            {
                TargetType = typeof(Border),
                Setters = { new Setter { Property = Border.CornerRadiusProperty, Value = new CornerRadius(5) } }
            };

            StackPanel stackPanel_ScrollViewer_Group = new StackPanel();
            stackPanel_ScrollViewer_Group.Orientation = Orientation.Vertical;
            stackPanel_ScrollViewer_Group.HorizontalAlignment = HorizontalAlignment.Left;
            stackPanel_ScrollViewer_Group.VerticalAlignment = VerticalAlignment.Top;
            stackPanel_ScrollViewer_Group.Margin = new Thickness(75, 5, 75, 0);

            //Scroll for Groups
            ScrollViewer scrollViewer_ItemGroups = new ScrollViewer();
            scrollViewer_ItemGroups.HorizontalScrollBarVisibility = ScrollBarVisibility.Hidden;
            scrollViewer_ItemGroups.VerticalScrollBarVisibility = ScrollBarVisibility.Hidden;
            scrollViewer_ItemGroups.Margin = new Thickness(0, 0, 0, 0);

            //Main StackPanel for Item Groups
            StackPanel stackPanel_ItemGroups = new StackPanel();
            stackPanel_ItemGroups.Orientation = Orientation.Horizontal;
            stackPanel_ItemGroups.Margin = new Thickness(0, 0, 0, 0);
            stackPanel_ItemGroups.HorizontalAlignment = HorizontalAlignment.Left;
            stackPanel_ItemGroups.VerticalAlignment = VerticalAlignment.Top;

            //---------------------------------//
            ItemGroupButtons itemGroupButtons = new ItemGroupButtons();
            //MessageBox.Show(itemGroupButtons.GrouNames.Count.ToString());

            //ItemGroup Variables
            int GroupButtonCount = itemGroupButtons.GroupNames.Count;

            int groupButtonHeight = 90;
            int groupButtonWidth = 100;
            //int groupButtonMargin_left = 5;
            //int groupButtonMargin_top = 5;

            StackPanel newStackPanel_group = new StackPanel();
            newStackPanel_group.Orientation = Orientation.Horizontal;
            newStackPanel_group.Name = "StackPanelGroup";
            stackPanel_ItemGroups.Children.Add(newStackPanel_group);



            for (int columns = 1; columns <= GroupButtonCount; columns++)
            {
                ItemGroupButtons itemGroup = new ItemGroupButtons(columns);

                Grid G = new Grid();
                Button B = new Button();
                TextBlock TB = new TextBlock();
                TB.Text = itemGroup.GroupName;
                B.Name = "_" + itemGroup.GroupId.ToString();
                TB.TextWrapping = TextWrapping.Wrap;
                TB.TextAlignment = TextAlignment.Center;

                G.Children.Add(TB);
                B.Content = G;
                B.Height = groupButtonHeight;
                B.Width = groupButtonWidth;
                B.FontSize = 19;
                B.Margin = new Thickness(2.5, 5, 2.5, 5);
                B.Background = (SolidColorBrush)(new BrushConverter().ConvertFrom("#57AFF7"));
                B.Click += button_Click;
                B.Resources.Add(style.TargetType, style);
                newStackPanel_group.Children.Add(B);
            }

            //--    Add Content to Grid     --//            
            RepeatButton button_left = new RepeatButton();
            button_left.HorizontalAlignment = HorizontalAlignment.Left;
            button_left.VerticalAlignment = VerticalAlignment.Top;
            button_left.Margin = new Thickness(5, 5, 0, 0);
            button_left.Content = "◀";
            button_left.FontSize = 50;
            button_left.Height = 100;
            button_left.Width = 65;
            button_left.Background = Brushes.LightBlue;
            button_left.Click += (s, e) =>
            {
                scrollViewer_ItemGroups.ScrollToHorizontalOffset(scrollViewer_ItemGroups.HorizontalOffset - 20);
            };
            button_left.Resources.Add(style.TargetType, style);


            RepeatButton button_right = new RepeatButton();
            button_right.HorizontalAlignment = HorizontalAlignment.Right;
            button_right.VerticalAlignment = VerticalAlignment.Top;
            button_right.Margin = new Thickness(0, 5, 5, 0);
            button_right.Content = "▶";
            button_right.FontSize = 50;
            button_right.Height = 100;
            button_right.Width = 65;
            button_right.Background = Brushes.LightBlue;
            button_right.Click += (s, e) =>
            {
                scrollViewer_ItemGroups.ScrollToHorizontalOffset(scrollViewer_ItemGroups.HorizontalOffset + 20);
            };
            button_right.Resources.Add(style.TargetType, style);

            MainGrid.Children.Add(button_left);
            MainGrid.Children.Add(button_right);


            scrollViewer_ItemGroups.Content = stackPanel_ItemGroups;
            stackPanel_ScrollViewer_Group.Children.Add(scrollViewer_ItemGroups);
            MainGrid.Children.Add(stackPanel_ScrollViewer_Group);


            //First Time, defualt group is first one
            if (ItemGroupId == 0)
            {
                itemGroupButtons = new ItemGroupButtons(1);
                ItemGroupId = itemGroupButtons.GroupId;
            }


        }

        private void AddContent()
        {

            Style style = new Style
            {
                TargetType = typeof(Border),
                Setters = { new Setter { Property = Border.CornerRadiusProperty, Value = new CornerRadius(5) } }
            };

            StackPanel stackPanel_ScrollViewer_Item = new StackPanel();
            stackPanel_ScrollViewer_Item.Orientation = Orientation.Horizontal;
            stackPanel_ScrollViewer_Item.HorizontalAlignment = HorizontalAlignment.Left;
            stackPanel_ScrollViewer_Item.VerticalAlignment = VerticalAlignment.Top;
            stackPanel_ScrollViewer_Item.Margin = new Thickness(0, 110, 0, 10);

            //Scroll for Items
            ScrollViewer scrollViewer_Items = new ScrollViewer();
            scrollViewer_Items.VerticalScrollBarVisibility = ScrollBarVisibility.Visible;
            scrollViewer_Items.Margin = new Thickness(0, 0, 0, 100);

            Style ScrollViewerStyle = (Style)Application.Current.Resources["scrollbar"];
            scrollViewer_Items.Style = ScrollViewerStyle;

            //Main StackPanel for Items
            StackPanel stackPanel_Main = new StackPanel();
            stackPanel_Main.Orientation = Orientation.Vertical;
            stackPanel_Main.Margin = new Thickness(0, 0, 0, 0);
            stackPanel_Main.HorizontalAlignment = HorizontalAlignment.Left;
            stackPanel_Main.VerticalAlignment = VerticalAlignment.Top;

            ItemButtons itemButtons = new ItemButtons(ItemGroupId);


            //----------------------------------------//
            //Variables for Items
            int ButtonCount = itemButtons.ItemNames.Count;
            double ScreenWidth = GetGridWidth() - 10;
            double ButtonWidth = 100;
            double ButtonHeight = 100;
            int ButtonMargin_left = 5;
            int ButtonMargin_top = 5;
            double ButtonWidthMargin = ButtonWidth + ButtonMargin_left;
            int ColumnsInRow = Convert.ToInt32(Math.Floor(ScreenWidth / ButtonWidthMargin));
            int NumberOfRows = Convert.ToInt32(Math.Ceiling((double)ButtonCount / (double)ColumnsInRow));
            int LastRowColumnCount = ButtonCount - (ColumnsInRow * (NumberOfRows - 1));

            if (ButtonCount < ColumnsInRow)
            {
                scrollViewer_Items.VerticalScrollBarVisibility = ScrollBarVisibility.Hidden;
            }
                       
            double Diff_margin = Math.Abs(GetGridWidth() - (ColumnsInRow * ButtonWidthMargin)) - 5;
            
            int ButtonCounter = 1;

            for (int rows = 1; rows <= NumberOfRows; rows++)
            {
                StackPanel newStackPanel = new StackPanel();
                newStackPanel.Orientation = Orientation.Horizontal;
                newStackPanel.Name = "StackPanel" + rows.ToString();
                newStackPanel.Margin = new Thickness(70, 0, Diff_margin, 0);
                stackPanel_Main.Children.Add(newStackPanel);

                //----------------------------------------//
                if (rows == NumberOfRows) //On Last Row
                {
                    for (int columns = 1; columns <= LastRowColumnCount; columns++)
                    {

                        ItemButtons itemButton = new ItemButtons(ItemGroupId, ButtonCounter);

                        Grid G = new Grid();
                        Button B = new Button();
                        TextBlock TB = new TextBlock();
                        TB.Text = itemButton.ButtonText;
                        B.Name = "_" + itemButton.ItemId.ToString();
                        TB.TextWrapping = TextWrapping.Wrap;
                        TB.TextAlignment = TextAlignment.Center;

                        G.Children.Add(TB);
                        B.Content = G;
                        B.Height = ButtonHeight;
                        B.Width = ButtonWidth;
                        B.FontFamily = new FontFamily(itemButton.Font);
                        B.FontSize = itemButton.FontSize;
                        B.Margin = new Thickness(2.5, 5, 2.5, 5);
                        B.Background = (SolidColorBrush)(new BrushConverter().ConvertFrom(itemButton.Hexa));
                        B.Click += ItemButton_Click;
                        B.Resources.Add(style.TargetType, style);
                        newStackPanel.Children.Add(B);

                        ButtonCounter += 1;
                    }
                }
                else
                {
                    for (int columns = 1; columns <= ColumnsInRow; columns++)
                    {

                        ItemButtons itemButton = new ItemButtons(ItemGroupId, ButtonCounter);

                        Grid G = new Grid();
                        Button B = new Button();
                        TextBlock TB = new TextBlock();
                        TB.Text = itemButton.ButtonText;
                        B.Name = "_" + itemButton.ItemId.ToString();
                        TB.TextWrapping = TextWrapping.Wrap;
                        TB.TextAlignment = TextAlignment.Center;

                        G.Children.Add(TB);
                        B.Content = G;
                        B.Height = ButtonHeight;
                        B.Width = ButtonWidth;
                        B.FontFamily = new FontFamily(itemButton.Font);
                        B.FontSize = itemButton.FontSize;
                        B.Margin = new Thickness(2.5, 5, 2.5, 5);
                        B.Background = (SolidColorBrush)(new BrushConverter().ConvertFrom(itemButton.Hexa));
                        B.Click += ItemButton_Click;
                        B.Resources.Add(style.TargetType, style);
                        newStackPanel.Children.Add(B);

                        ButtonCounter += 1;

                    }
                }



            }

            scrollViewer_Items.Content = stackPanel_Main;
            stackPanel_ScrollViewer_Item.Children.Add(scrollViewer_Items);
            MainGrid.Children.Add(stackPanel_ScrollViewer_Item);




            //Back Button
            StackPanel stackPanel_Bottom = new StackPanel();
            stackPanel_Bottom.Orientation = Orientation.Vertical;
            stackPanel_Bottom.Margin = new Thickness(0, 0, 0, 0);
            stackPanel_Bottom.HorizontalAlignment = HorizontalAlignment.Right;
            stackPanel_Bottom.VerticalAlignment = VerticalAlignment.Bottom;

            Grid Back_G = new Grid();
            Button Back_B = new Button();
            TextBlock Back_TB = new TextBlock();
            Back_TB.Text = "Back";
            Back_B.Name = "btn_Back";
            Back_TB.TextWrapping = TextWrapping.Wrap;
            Back_TB.TextAlignment = TextAlignment.Center;

            Back_G.Children.Add(Back_TB);
            Back_B.Content = Back_G;
            Back_B.Height = 80;
            Back_B.Width = 150;
            Back_B.Background = Brushes.CornflowerBlue;
            Back_B.Margin = new Thickness(0, 0, 5, 5);
            Back_B.FontSize = 25;
            Back_B.Resources.Add(style.TargetType, style);
            Back_B.Click += BackButton_Click;

            stackPanel_Bottom.Children.Add(Back_B);
            MainGrid.Children.Add(stackPanel_Bottom);

        }

        private void Main_Window_SizeChanged(object sender, SizeChangedEventArgs e)
        {

            if (GetGridWidth() >= 150)
            {
                MainGrid.Children.Clear();

                AddGroupContent();
                AddContent();
            }



        }
    }
}
