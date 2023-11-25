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
using System.Threading;

namespace POSSystem_Retail
{
    /// <summary>
    /// Interaction logic for ErrorDialog.xaml
    /// </summary>
    public partial class MessageDialog : Window
    {
        public MessageDialog(string Title, string Message)
        {
            InitializeComponent();

            this.Title = Title;
            tbx_Message.Text = Message;

        }

        private void Btn_OK_Click(object sender, RoutedEventArgs e)
        {
            //OK
            GlobalVaraibles.MessageDecision = true;
            this.Close();
        }

        private void Window_KeyUp(object sender, KeyEventArgs e)
        {
           
        }

        private void btn_Cancel_Click(object sender, RoutedEventArgs e)
        {
            //CANCEL
            GlobalVaraibles.MessageDecision = false;
            this.Close();
        }
    }
}
